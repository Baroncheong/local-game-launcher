# Import game archives (zip/rar/7z, several at once) into a games folder:
# extract, drop wrapper folders, offer to extract archives found inside (repeats), then move each archive into <Zips>\<game>
param([Parameter(Mandatory)][string]$Root, [string[]]$Files, [switch]$Quiet, [string]$Password = '', [string]$Zips = (Join-Path $PSScriptRoot 'Game Zips'))  # -Files/-Quiet: skip dialogs (testing)
. "$PSScriptRoot\ui.ps1"
$7z = 'C:\Program Files\7-Zip\7z.exe'
function Say($m) { if ($Quiet) { Write-Host $m } else { Show-UiMessage $m (T '匯入遊戲') } }
if (-not (Test-Path $7z)) { Say (T '搵唔到 7-Zip：{0}' $7z); exit 1 }

if (-not $Files) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = T '揀遊戲壓縮檔，可以一次揀幾個（會解壓去 {0}）' $Root
  $dlg.Filter = (T '壓縮檔') + '|*.zip;*.rar;*.7z|' + (T '全部') + '|*.*'
  $dlg.Multiselect = $true
  $dlg.InitialDirectory = "$env:USERPROFILE\Downloads"
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $Files = $dlg.FileNames
}
$pw = $Password
if (-not $Quiet) { $pw = Ask-Password (T '解壓密碼（{0} 個檔案共用）' @($Files).Count); if ($null -eq $pw) { exit 0 } }

$isFirstPart = { param($p) $p -notmatch '\.part0*([2-9]|\d{2,})\.rar$' }   # multi-part rar: 7-Zip only needs part1
function Parts($arc) { if ($arc -match '^(.*)\.part0*1\.rar$') { @(Get-ChildItem -LiteralPath (Split-Path $arc) -Filter "$(Split-Path $Matches[1] -Leaf).part*.rar" | ForEach-Object FullName) } else { @($arc) } }

# Extract $arc into $out. Tries the chosen password, then every remembered one, then asks. Returns $true on success.
function Expand-Archive7z($arc, $out) {
  $tries = @($pw) + @(Get-SavedPasswords | Where-Object { $_ -ne $pw })
  foreach ($p in $tries) {
    $log = & $7z x $arc "-o$out" "-p$p" -y 2>&1 | Out-String   # always pass -p so 7-Zip never waits on the console
    if ($LASTEXITCODE -eq 0) { return $true }
    Remove-Item -LiteralPath $out -Recurse -Force -ErrorAction SilentlyContinue   # our own half-extracted folder only
    if ($log -notmatch 'Wrong password|encrypted') { return $false }               # broken file / no space: don't keep trying passwords
  }
  if ($Quiet) { return $false }
  $p2 = Ask-Password (T '{0} 密碼唔啱' (Split-Path $arc -Leaf)) (T '再試一次？')
  if (-not $p2) { return $false }
  & $7z x $arc "-o$out" "-p$p2" -y | Out-Null
  if ($LASTEXITCODE -eq 0) { return $true }
  Remove-Item -LiteralPath $out -Recurse -Force -ErrorAction SilentlyContinue; return $false
}
function Move-ToZips($arc, $zipDir) {
  New-Item -ItemType Directory -Force $zipDir | Out-Null
  foreach ($p in (Parts $arc)) { if ((Test-Path -LiteralPath $p) -and -not (Test-Path -LiteralPath (Join-Path $zipDir (Split-Path $p -Leaf)))) { Move-Item -LiteralPath $p $zipDir } }
}
function Free-Path($path) { $n = 2; $p = $path; while (Test-Path -LiteralPath $p) { $p = "$path ($n)"; $n++ }; $p }  # never overwrite

$files = @($Files | Where-Object { & $isFirstPart $_ })
$ok = @(); $bad = @(); $i = 0
foreach ($arc in $files) {
  $i++
  Write-Host (T '[{0}/{1}] 解壓緊 {2} ...' $i $files.Count (Split-Path $arc -Leaf))
  $name = [IO.Path]::GetFileNameWithoutExtension($arc) -replace '\.part0*1$', ''
  $tmp = Join-Path $Root "_importing_$([guid]::NewGuid().ToString('N').Substring(0,8))"
  if (-not (Expand-Archive7z $arc $tmp)) { $bad += T '{0}（密碼唔啱、檔案壞咗或者唔夠位）' (Split-Path $arc -Leaf); continue }
  # descend while there is exactly one folder and nothing else
  $src = $tmp
  while ($true) {
    $items = @(Get-ChildItem -LiteralPath $src -Force | Where-Object Name -ne '__MACOSX')
    if ($items.Count -eq 1 -and $items[0].PSIsContainer) { $src = $items[0].FullName } else { break }
  }
  if ($src -ne $tmp) { $name = Split-Path $src -Leaf }
  $dest = Free-Path (Join-Path $Root $name)
  Move-Item -LiteralPath $src $dest
  if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
  $zipDir = Join-Path $Zips (Split-Path $dest -Leaf)
  Move-ToZips $arc $zipDir

  # archives inside the extracted game: list them, extract the ones picked, and look again inside those
  $scan = @($dest); $asked = @{}
  while ($scan.Count -and -not $Quiet) {
    $found = @(foreach ($d in $scan) { Get-ChildItem -LiteralPath $d -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in '.zip', '.rar', '.7z' -and (& $isFirstPart $_.FullName) -and -not $asked[$_.FullName] } })
    $scan = @()
    if (-not $found.Count) { break }
    foreach ($f in $found) { $asked[$f.FullName] = $true }
    $rel = @($found | ForEach-Object { $_.FullName.Substring($dest.Length + 1) })
    $pick = Select-UiItems (T '{0}：入面仲有壓縮檔' (Split-Path $dest -Leaf)) (T "解壓完發現入面仲有 {0} 個壓縮檔。剔咗嘅會再解壓（壓縮檔之後搬入 Game Zips）。`n遊戲本身用嘅資料檔可以唔剔。" $found.Count) $rel
    if (-not $pick) { break }
    foreach ($r in $pick) {
      $inner = Join-Path $dest $r
      $out = Free-Path (Join-Path (Split-Path $inner) ([IO.Path]::GetFileNameWithoutExtension($inner) -replace '\.part0*1$', ''))
      if (Expand-Archive7z $inner $out) { Move-ToZips $inner $zipDir; $scan += $out } else { $bad += T '{0}（喺 {1} 入面）' $r (Split-Path $dest -Leaf) }
    }
  }
  $ok += Split-Path $dest -Leaf
}

$msg = (T "匯入咗 {0} 隻：`n" $ok.Count) + ($ok -join "`n")
if ($bad) { $msg += (T "`n`n失敗（原本個壓縮檔冇郁過）：`n") + ($bad -join "`n") }
if ($ok) { $msg += T "`n`n新遊戲會喺遊戲庫等你檢查同確認先加入。" }
Say $msg
