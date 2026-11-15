# Import game archives (zip/rar/7z, several at once) into a games folder:
# extract, drop wrapper folders, then move each archive into <Zips>\<game>
param([Parameter(Mandatory)][string]$Root, [string[]]$Files, [switch]$Quiet, [string]$Password = '', [string]$Zips = (Join-Path $PSScriptRoot 'Game Zips'))  # -Files/-Quiet: skip dialogs (testing)
Add-Type -AssemblyName System.Windows.Forms
$7z = 'C:\Program Files\7-Zip\7z.exe'
function Say($m) { if ($Quiet) { Write-Host $m } else { [System.Windows.Forms.MessageBox]::Show($m, '匯入遊戲') | Out-Null } }
if (-not (Test-Path $7z)) { Say "搵唔到 7-Zip：$7z"; exit 1 }

if (-not $Files) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = "揀遊戲壓縮檔，可以一次揀幾個（會解壓去 $Root）"
  $dlg.Filter = '壓縮檔|*.zip;*.rar;*.7z|全部|*.*'
  $dlg.Multiselect = $true
  $dlg.InitialDirectory = "$env:USERPROFILE\Downloads"
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $Files = $dlg.FileNames
}

# Ask whether to use a password. Returns '' for none, $null if cancelled.
function AskPassword($title) {
  $f = New-Object System.Windows.Forms.Form -Property @{ Text = $title; Width = 380; Height = 190; StartPosition = 'CenterScreen'; FormBorderStyle = 'FixedDialog'; MaximizeBox = $false; MinimizeBox = $false; TopMost = $true }
  $cb = New-Object System.Windows.Forms.CheckBox -Property @{ Text = '用密碼解壓'; Left = 20; Top = 20; Width = 300 }
  $tb = New-Object System.Windows.Forms.TextBox -Property @{ Left = 20; Top = 50; Width = 320; Enabled = $false; UseSystemPasswordChar = $false }
  $cb.Add_CheckedChanged({ $tb.Enabled = $cb.Checked; if ($cb.Checked) { $tb.Focus() } })
  $okB = New-Object System.Windows.Forms.Button -Property @{ Text = '開始'; Left = 180; Top = 95; Width = 75; DialogResult = 'OK' }
  $noB = New-Object System.Windows.Forms.Button -Property @{ Text = '取消'; Left = 265; Top = 95; Width = 75; DialogResult = 'Cancel' }
  $f.Controls.AddRange(@($cb, $tb, $okB, $noB)); $f.AcceptButton = $okB; $f.CancelButton = $noB
  if ($f.ShowDialog() -ne 'OK') { return $null }
  if ($cb.Checked) { return $tb.Text } else { return '' }
}
$pw = $Password
if (-not $Quiet) { $pw = AskPassword "密碼？（$(@($Files).Count) 個檔案共用）"; if ($null -eq $pw) { exit 0 } }

# multi-part rars: only extract part1 (7-Zip pulls in the rest), move all parts afterwards
$files = @($Files | Where-Object { $_ -notmatch '\.part0*([2-9]|\d{2,})\.rar$' })
$ok = @(); $bad = @(); $i = 0

foreach ($arc in $files) {
  $i++
  Write-Host "[$i/$($files.Count)] 解壓緊 $(Split-Path $arc -Leaf) ..."
  $name = [IO.Path]::GetFileNameWithoutExtension($arc) -replace '\.part0*1$', ''
  $tmp = Join-Path $Root "_importing_$([guid]::NewGuid().ToString('N').Substring(0,8))"
  $log = & $7z x $arc "-o$tmp" "-p$pw" -y 2>&1 | Out-String  # always pass -p so 7-Zip never waits on the console
  if ($LASTEXITCODE -ne 0 -and -not $Quiet -and $log -match 'Wrong password|encrypted') {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    $p2 = AskPassword "$(Split-Path $arc -Leaf) 密碼唔啱，再試？"
    if ($p2) { & $7z x $arc "-o$tmp" "-p$p2" -y | Out-Null }
  }
  if ($LASTEXITCODE -ne 0) {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue  # our own half-extracted temp only
    $bad += "$(Split-Path $arc -Leaf)（可能要密碼、檔案壞咗或者唔夠位）"; continue
  }
  # descend while there is exactly one folder and nothing else
  $src = $tmp
  while ($true) {
    $items = @(Get-ChildItem $src -Force | Where-Object Name -ne '__MACOSX')
    if ($items.Count -eq 1 -and $items[0].PSIsContainer) { $src = $items[0].FullName } else { break }
  }
  if ($src -ne $tmp) { $name = Split-Path $src -Leaf }
  $dest = Join-Path $Root $name; $n = 2
  while (Test-Path $dest) { $dest = Join-Path $Root "$name ($n)"; $n++ }  # never overwrite an existing game
  Move-Item $src $dest
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }

  $zipDir = Join-Path $Zips (Split-Path $dest -Leaf)  # archives live in <Zips>\<game>
  New-Item -ItemType Directory -Force $zipDir | Out-Null
  $parts = @($arc)
  if ($arc -match '^(.*)\.part0*1\.rar$') { $parts = @(Get-ChildItem "$($Matches[1]).part*.rar" | ForEach-Object FullName) }
  foreach ($p in $parts) { if (-not (Test-Path (Join-Path $zipDir (Split-Path $p -Leaf)))) { Move-Item $p $zipDir } }
  $ok += Split-Path $dest -Leaf
}

$msg = "匯入咗 $($ok.Count) 隻：`n" + ($ok -join "`n")
if ($bad) { $msg += "`n`n失敗（原本個壓縮檔冇郁過）：`n" + ($bad -join "`n") }
Say $msg
