# Shared dialogs for the launcher's helper scripts, in the launcher's neon style
# (near-black panel, yellow + cyan accents, Consolas). Dot-source it: . "$PSScriptRoot\ui.ps1"
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$script:UI = @{
  Bg = [Drawing.Color]::FromArgb(11, 13, 20); Panel = [Drawing.Color]::FromArgb(16, 20, 30); Fg = [Drawing.Color]::FromArgb(232, 247, 255)
  Yellow = [Drawing.Color]::FromArgb(252, 238, 10); Cyan = [Drawing.Color]::FromArgb(0, 240, 255); Dim = [Drawing.Color]::FromArgb(61, 107, 120)
  Font = New-Object Drawing.Font('Microsoft JhengHei', 10); Title = New-Object Drawing.Font('Consolas', 13, [Drawing.FontStyle]::Bold)
}

function New-UiForm([string]$Title, [int]$Width, [int]$Height) {
  $f = New-Object Windows.Forms.Form -Property @{ Text = $Title; Width = $Width; Height = $Height; StartPosition = 'CenterScreen'; FormBorderStyle = 'FixedDialog'
    MaximizeBox = $false; MinimizeBox = $false; TopMost = $true; BackColor = $UI.Bg; ForeColor = $UI.Fg; Font = $UI.Font; ShowIcon = $false }
  $logo = Join-Path $PSScriptRoot 'logo.ico'; if (Test-Path $logo) { try { $f.Icon = New-Object Drawing.Icon $logo; $f.ShowIcon = $true } catch {} }
  $bar = New-Object Windows.Forms.Panel -Property @{ Dock = 'Top'; Height = 4; BackColor = $UI.Yellow }; $f.Controls.Add($bar)
  $h = New-Object Windows.Forms.Label -Property @{ Text = "// $Title"; Left = 18; Top = 14; Width = $Width - 50; Height = 26; ForeColor = $UI.Yellow; Font = $UI.Title }
  $f.Controls.Add($h); return $f
}
function New-UiLabel($form, [string]$Text, [int]$Top, [int]$Height = 22) {
  $l = New-Object Windows.Forms.Label -Property @{ Text = $Text; Left = 18; Top = $Top; Width = $form.ClientSize.Width - 36; Height = $Height; ForeColor = $UI.Cyan }
  $form.Controls.Add($l); return $l
}
function New-UiText($form, [string]$Text, [int]$Top) {
  $t = New-Object Windows.Forms.TextBox -Property @{ Text = $Text; Left = 18; Top = $Top; Width = $form.ClientSize.Width - 36; BackColor = $UI.Panel; ForeColor = $UI.Fg; BorderStyle = 'FixedSingle' }
  $form.Controls.Add($t); return $t
}
function New-UiButton($form, [string]$Text, [int]$Left, [int]$Top, [string]$Result, [switch]$Primary) {
  $b = New-Object Windows.Forms.Button -Property @{ Text = $Text; Left = $Left; Top = $Top; Width = 110; Height = 32; FlatStyle = 'Flat'; DialogResult = $Result; Cursor = 'Hand' }
  if ($Primary) { $b.BackColor = $UI.Yellow; $b.ForeColor = $UI.Bg; $b.FlatAppearance.BorderColor = $UI.Yellow }
  else { $b.BackColor = $UI.Bg; $b.ForeColor = $UI.Cyan; $b.FlatAppearance.BorderColor = $UI.Cyan }
  $form.Controls.Add($b); return $b
}
# OK / Cancel pair on the bottom right
function Add-UiButtons($form, [string]$OkText = '確定', [string]$CancelText = '取消') {
  $w = $form.ClientSize.Width; $y = $form.ClientSize.Height - 48
  $ok = New-UiButton $form $OkText ($w - 248) $y 'OK' -Primary; $no = New-UiButton $form $CancelText ($w - 128) $y 'Cancel'
  $form.AcceptButton = $ok; $form.CancelButton = $no
}
function Show-UiMessage([string]$Text, [string]$Title = '遊戲庫') {
  $lines = [Math]::Max(2, ($Text -split "`n").Count); $f = New-UiForm $Title 520 ([Math]::Min(640, 150 + $lines * 22))
  $l = New-Object Windows.Forms.Label -Property @{ Text = $Text; Left = 18; Top = 50; Width = 470; Height = $f.ClientSize.Height - 110; ForeColor = $UI.Fg }
  $f.Controls.Add($l); $ok = New-UiButton $f '好' ($f.ClientSize.Width - 128) ($f.ClientSize.Height - 48) 'OK' -Primary; $f.AcceptButton = $ok
  [void]$f.ShowDialog()
}
function Confirm-Ui([string]$Text, [string]$Title, [string]$OkText = '確定') {
  $lines = [Math]::Max(2, ($Text -split "`n").Count); $f = New-UiForm $Title 560 ([Math]::Min(640, 150 + $lines * 22))
  $l = New-Object Windows.Forms.Label -Property @{ Text = $Text; Left = 18; Top = 50; Width = 510; Height = $f.ClientSize.Height - 110; ForeColor = $UI.Fg }
  $f.Controls.Add($l); Add-UiButtons $f $OkText; return ($f.ShowDialog() -eq 'OK')
}

# ---- remembered archive passwords (passwords.dat, one Windows-encrypted line each; only this Windows user can read them) ----
$script:PwFile = Join-Path $PSScriptRoot 'passwords.dat'
function Get-SavedPasswords {
  if (-not (Test-Path $PwFile)) { return @() }
  @(Get-Content $PwFile | Where-Object { $_ } | ForEach-Object {
    try { $s = ConvertTo-SecureString $_; [Runtime.InteropServices.Marshal]::PtrToStringUni([Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($s)) } catch {} })
}
function Save-Password([string]$pw) {
  if (-not $pw -or (Get-SavedPasswords) -contains $pw) { return }
  Add-Content $PwFile (ConvertTo-SecureString $pw -AsPlainText -Force | ConvertFrom-SecureString)
}
# Returns '' for no password, $null if cancelled. Lists remembered passwords to pick from.
function Ask-Password([string]$Title, [string]$Note = '') {
  $saved = Get-SavedPasswords
  $f = New-UiForm $Title 520 300
  $cb = New-Object Windows.Forms.CheckBox -Property @{ Text = '用密碼解壓'; Left = 18; Top = 50; Width = 470; ForeColor = $UI.Fg; Checked = [bool]$saved.Count }
  $f.Controls.Add($cb)
  New-UiLabel $f ('密碼（可以揀用過嘅，或者打新嘅）' + $(if ($Note) { "  $Note" })) 82 | Out-Null
  $box = New-Object Windows.Forms.ComboBox -Property @{ Left = 18; Top = 106; Width = 470; BackColor = $UI.Panel; ForeColor = $UI.Fg; FlatStyle = 'Flat'; DropDownStyle = 'DropDown' }
  foreach ($p in $saved) { [void]$box.Items.Add($p) }; if ($saved.Count) { $box.SelectedIndex = 0 }
  $f.Controls.Add($box)
  $rem = New-Object Windows.Forms.CheckBox -Property @{ Text = '記住呢個密碼，下次可以直接揀'; Left = 18; Top = 142; Width = 470; ForeColor = $UI.Cyan; Checked = $true }
  $f.Controls.Add($rem)
  $sync = { $box.Enabled = $cb.Checked; $rem.Enabled = $cb.Checked }; $cb.Add_CheckedChanged($sync); & $sync
  Add-UiButtons $f '開始'
  if ($f.ShowDialog() -ne 'OK') { return $null }
  if (-not $cb.Checked) { return '' }
  if ($rem.Checked) { Save-Password $box.Text }
  return $box.Text
}
# Checklist dialog: returns the checked items (strings), or $null if cancelled
function Select-UiItems([string]$Title, [string]$Text, [string[]]$Items) {
  $f = New-UiForm $Title 720 520
  New-UiLabel $f $Text 48 40 | Out-Null
  $list = New-Object Windows.Forms.CheckedListBox -Property @{ Left = 18; Top = 92; Width = 670; Height = 320; BackColor = $UI.Panel; ForeColor = $UI.Fg; BorderStyle = 'FixedSingle'; CheckOnClick = $true }
  foreach ($i in $Items) { [void]$list.Items.Add($i, $true) }
  $f.Controls.Add($list); Add-UiButtons $f '解壓揀咗嘅' '全部唔要'
  if ($f.ShowDialog() -ne 'OK') { return $null }
  return @($list.CheckedItems | ForEach-Object { [string]$_ })
}
