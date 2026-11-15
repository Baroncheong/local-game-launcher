# Add an already-extracted game to the library by picking its exe. Nothing is moved:
# the game is listed in extra-games.txt (UTF-16, "name<TAB>exe path" per line).
param([string]$Exe, [string]$Name)  # params: skip dialogs (testing)
Add-Type -AssemblyName System.Windows.Forms, Microsoft.VisualBasic
$list = Join-Path $PSScriptRoot 'extra-games.txt'
if (-not $Exe) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = '揀遊戲嘅 exe（或者捷徑）'
  $dlg.Filter = '遊戲程式|*.exe;*.lnk|全部|*.*'
  $dlg.DereferenceLinks = $false
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $Exe = $dlg.FileName
  $default = Split-Path (Split-Path $Exe) -Leaf
  $Name = [Microsoft.VisualBasic.Interaction]::InputBox('遊戲庫入面顯示乜名？', '加入遊戲', $default)
  if (-not $Name.Trim()) { exit 0 }  # cancelled
}
$Name = $Name.Trim() -replace "[`t`r`n]", ' '
$lines = @(); if (Test-Path $list) { $lines = @([IO.File]::ReadAllLines($list, [Text.Encoding]::Unicode) | Where-Object { $_ }) }
$lines = @($lines | Where-Object { ($_ -split "`t")[1] -ne $Exe }) + "$Name`t$Exe"  # same exe added again = rename
[IO.File]::WriteAllLines($list, $lines, [Text.Encoding]::Unicode)
if (-not $PSBoundParameters.Count) { [System.Windows.Forms.MessageBox]::Show("加咗「$Name」入遊戲庫。`n想要封面：將圖改名做「$Name.jpg」放入遊戲庫嘅 covers 資料夾（⚙ 設定 → 打開封面資料夾）", '加入遊戲') | Out-Null }
