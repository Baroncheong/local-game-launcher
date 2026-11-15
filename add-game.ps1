# Add an already-extracted game to the library by picking its exe. Nothing is moved:
# the game is listed in extra-games.txt (UTF-16, "name<TAB>exe path<TAB>category" per line).
param([string]$Categories = '', [string]$Exe, [string]$Name, [string]$Category = '', [string]$Default = '')  # -Exe/-Name/-Category: skip dialogs (testing)
Add-Type -AssemblyName System.Windows.Forms
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
  $f = New-Object System.Windows.Forms.Form -Property @{ Text = '加入遊戲'; Width = 420; Height = 220; StartPosition = 'CenterScreen'; FormBorderStyle = 'FixedDialog'; MaximizeBox = $false; MinimizeBox = $false; TopMost = $true }
  $l1 = New-Object System.Windows.Forms.Label -Property @{ Text = '顯示嘅名'; Left = 20; Top = 15; Width = 360 }
  $tb = New-Object System.Windows.Forms.TextBox -Property @{ Left = 20; Top = 38; Width = 360; Text = (Split-Path (Split-Path $Exe) -Leaf) }
  $l2 = New-Object System.Windows.Forms.Label -Property @{ Text = '類別'; Left = 20; Top = 72; Width = 360 }
  $cb = New-Object System.Windows.Forms.ComboBox -Property @{ Left = 20; Top = 95; Width = 360; DropDownStyle = 'DropDownList' }
  foreach ($c in @($Categories -split '\|' | Where-Object { $_ }) + $other) { [void]$cb.Items.Add($c) }
  $cb.SelectedIndex = [Math]::Max(0, $cb.Items.IndexOf($Default))  # preselect the section whose + was clicked
  $okB = New-Object System.Windows.Forms.Button -Property @{ Text = '加入'; Left = 220; Top = 135; Width = 75; DialogResult = 'OK' }
  $noB = New-Object System.Windows.Forms.Button -Property @{ Text = '取消'; Left = 305; Top = 135; Width = 75; DialogResult = 'Cancel' }
  $f.Controls.AddRange(@($l1, $tb, $l2, $cb, $okB, $noB)); $f.AcceptButton = $okB; $f.CancelButton = $noB
  if ($f.ShowDialog() -ne 'OK' -or -not $tb.Text.Trim()) { exit 0 }
  $Name = $tb.Text; $Category = [string]$cb.SelectedItem
  $ask = $true
}
if ($Category -eq $other) { $Category = '' }
$Name = $Name.Trim() -replace "[`t`r`n]", ' '
$lines = @(); if (Test-Path $list) { $lines = @([IO.File]::ReadAllLines($list, [Text.Encoding]::Unicode) | Where-Object { $_ }) }
$lines = @($lines | Where-Object { ($_ -split "`t")[1] -ne $Exe }) + "$Name`t$Exe`t$Category"  # same exe added again = rename / move category
[IO.File]::WriteAllLines($list, $lines, [Text.Encoding]::Unicode)
if ($ask) { [System.Windows.Forms.MessageBox]::Show("加咗「$Name」入遊戲庫。`n想要封面：撳佢，再揀「換封面」。", '加入遊戲') | Out-Null }
