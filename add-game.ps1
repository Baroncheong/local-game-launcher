# Add an already-extracted game to the library by picking its exe. Nothing is moved:
# the game is listed in extra-games.txt (UTF-16, "name<TAB>exe path<TAB>category" per line).
param([string]$Categories = '', [string]$Exe, [string]$Name, [string]$Category = '', [string]$Default = '')  # -Exe/-Name/-Category: skip dialogs (testing)
. "$PSScriptRoot\ui.ps1"
$list = Join-Path $PSScriptRoot 'extra-games.txt'
$other = '其他'
if (-not $Exe) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = '揀遊戲嘅 exe（或者捷徑）'
  $dlg.Filter = '遊戲程式|*.exe;*.lnk|全部|*.*'
  $dlg.DereferenceLinks = $false
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $Exe = $dlg.FileName

  # one small form: display name + which category it goes under
  $f = New-UiForm '加入遊戲' 520 290
  New-UiLabel $f '顯示嘅名' 50 | Out-Null
  $tb = New-UiText $f (Split-Path (Split-Path $Exe) -Leaf) 74
  New-UiLabel $f '類別' 110 | Out-Null
  $cb = New-Object System.Windows.Forms.ComboBox -Property @{ Left = 18; Top = 134; Width = 470; DropDownStyle = 'DropDownList'; BackColor = $UI.Panel; ForeColor = $UI.Fg; FlatStyle = 'Flat' }
  foreach ($c in @($Categories -split '\|' | Where-Object { $_ }) + $other) { [void]$cb.Items.Add($c) }
  $cb.SelectedIndex = [Math]::Max(0, $cb.Items.IndexOf($Default))  # preselect the section whose + was clicked
  $f.Controls.Add($cb); Add-UiButtons $f '加入'
  if ($f.ShowDialog() -ne 'OK' -or -not $tb.Text.Trim()) { exit 0 }
  $Name = $tb.Text; $Category = [string]$cb.SelectedItem
  $ask = $true
}
if ($Category -eq $other) { $Category = '' }
$Name = $Name.Trim() -replace "[`t`r`n]", ' '
$lines = @(); if (Test-Path $list) { $lines = @([IO.File]::ReadAllLines($list, [Text.Encoding]::Unicode) | Where-Object { $_ }) }
$lines = @($lines | Where-Object { ($_ -split "`t")[1] -ne $Exe }) + "$Name`t$Exe`t$Category"  # same exe added again = rename / move category
[IO.File]::WriteAllLines($list, $lines, [Text.Encoding]::Unicode)
if ($ask) { Show-UiMessage "加咗「$Name」入遊戲庫。`n想要封面：喺遊戲上面撳右鍵，揀「換封面」。" '加入遊戲' }
