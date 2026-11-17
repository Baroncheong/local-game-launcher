# Start a game in its own folder and record "last played" + play time in playtime.txt
# (UTF-16, "name<TAB>seconds<TAB>last played" per line; read by the launcher's game page).
param([Parameter(Mandatory)][string]$Target, [Parameter(Mandatory)][string]$Name, [switch]$NoLaunch, [int]$Add = 0)  # -NoLaunch/-Add: record only (testing)
$file = Join-Path $PSScriptRoot 'playtime.txt'
function Update([int]$add) {
  $secs = [ordered]@{}; $last = @{}
  if (Test-Path $file) {
    foreach ($l in [IO.File]::ReadAllLines($file, [Text.Encoding]::Unicode)) { $p = $l -split "`t"; if ($p[0]) { $secs[$p[0]] = [int]$p[1]; $last[$p[0]] = $p[2] } }
  }
  $secs[$Name] = [int]$secs[$Name] + $add
  $last[$Name] = (Get-Date).ToString('yyyy-MM-dd HH:mm')
  $lines = foreach ($k in $secs.Keys) { "$k`t$($secs[$k])`t$($last[$k])" }
  [IO.File]::WriteAllLines($file, [string[]]@($lines), [Text.Encoding]::Unicode)
}
$start = Get-Date
Update $Add   # last played = now
if ($NoLaunch) { exit 0 }
$p = Start-Process -FilePath $Target -WorkingDirectory (Split-Path $Target) -PassThru   # own folder as working dir (many VN engines need it)
# shortcut: only the process we started is timed; a game that relaunches itself (or a patcher shortcut) is under-counted
if ($p) { $p.WaitForExit(); Update ([int]((Get-Date) - $start).TotalSeconds) }
