# Shared dialogs for the launcher's helper scripts, in the launcher's neon style
# (near-black panel, yellow + cyan accents, Consolas). Dot-source it: . "$PSScriptRoot\ui.ps1"
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$script:UI = @{
  Bg = [Drawing.Color]::FromArgb(11, 13, 20); Panel = [Drawing.Color]::FromArgb(16, 20, 30); Fg = [Drawing.Color]::FromArgb(232, 247, 255)
  Yellow = [Drawing.Color]::FromArgb(252, 238, 10); Cyan = [Drawing.Color]::FromArgb(0, 240, 255); Dim = [Drawing.Color]::FromArgb(61, 107, 120)
  Font = New-Object Drawing.Font('Microsoft JhengHei', 10); Title = New-Object Drawing.Font('Consolas', 13, [Drawing.FontStyle]::Bold)
}

# ---- interface language: text is written in Traditional Chinese (Cantonese); lang= in config.txt picks another ----
$script:LangIx = @{ 'en' = 0; 'zh-CN' = 1; 'ja' = 2 }[((Get-Content (Join-Path $PSScriptRoot 'config.txt') -Encoding UTF8 -ErrorAction SilentlyContinue | Where-Object { $_ -match '^\s*lang\s*=' } | Select-Object -Last 1) -replace '^\s*lang\s*=\s*', '').Trim()]
$script:I18N = @{   # key -> English, Simplified Chinese, Japanese  ({0} {1} = values filled in)
  '全部唔要' = 'Skip all', '全部不要', 'すべてスキップ'
  '取消' = 'Cancel', '取消', 'キャンセル'
  '好' = 'OK', '好', 'OK'
  '確定' = 'OK', '确定', 'OK'
  '開始' = 'Start', '开始', '開始'
  '遊戲庫' = 'Game library', '游戏库', 'ゲームライブラリ'
  '用密碼解壓' = 'Extract with a password', '使用密码解压', 'パスワードで解凍'
  '密碼（可以揀用過嘅，或者打新嘅）' = 'Password (pick a saved one or type a new one)', '密码（可以选用过的，或输入新的）', 'パスワード（保存済みから選ぶか、新しく入力）'
  '記住呢個密碼，下次可以直接揀' = 'Remember this password for next time', '记住这个密码，下次可以直接选', 'このパスワードを記憶する'
  '解壓揀咗嘅' = 'Extract selected', '解压选中的', '選んだものを解凍'
  '匯入遊戲' = 'Import games', '导入游戏', 'ゲームを取り込む'
  '再試一次？' = 'Try again?', '再试一次？', 'もう一度試しますか？'
  '壓縮檔' = 'Archives', '压缩包', 'アーカイブ'
  '全部' = 'All files', '全部', 'すべて'
  '搵唔到 7-Zip：{0}' = '7-Zip not found: {0}', '找不到 7-Zip：{0}', '7-Zip が見つかりません：{0}'
  '揀遊戲壓縮檔，可以一次揀幾個（會解壓去 {0}）' = 'Pick game archives, several at once if you like (extracted to {0})', '选择游戏压缩包，可以一次选多个（会解压到 {0}）', 'ゲームのアーカイブを選択（複数可、{0} に解凍）'
  '解壓密碼（{0} 個檔案共用）' = 'Extraction password (shared by {0} files)', '解压密码（{0} 个文件共用）', '解凍パスワード（{0} 個のファイル共通）'
  '{0} 密碼唔啱' = '{0}: wrong password', '{0} 密码不对', '{0} のパスワードが違います'
  '[{0}/{1}] 解壓緊 {2} ...' = '[{0}/{1}] Extracting {2} ...', '[{0}/{1}] 正在解压 {2} ...', '[{0}/{1}] {2} を解凍中 ...'
  '{0}（密碼唔啱、檔案壞咗或者唔夠位）' = '{0} (wrong password, damaged file or not enough space)', '{0}（密码不对、文件损坏或空间不足）', '{0}（パスワード違い・ファイル破損・容量不足）'
  '{0}：入面仲有壓縮檔' = '{0}: more archives inside', '{0}：里面还有压缩包', '{0}：中にアーカイブがあります'
  "解壓完發現入面仲有 {0} 個壓縮檔。剔咗嘅會再解壓（壓縮檔之後搬入 Game Zips）。`n遊戲本身用嘅資料檔可以唔剔。" = "Found {0} more archives inside. Ticked ones will be extracted too (archives then move to Game Zips).`nLeave the game's own data files unticked.", "解压后发现里面还有 {0} 个压缩包。勾选的会再解压（压缩包之后移到 Game Zips）。`n游戏本身用的数据文件可以不勾。", "解凍した中にさらに {0} 個のアーカイブがあります。チェックしたものも解凍します（アーカイブは Game Zips に移動）。`nゲーム本体のデータファイルはチェック不要です。"
  '{0}（喺 {1} 入面）' = '{0} (inside {1})', '{0}（在 {1} 里面）', '{0}（{1} の中）'
  "匯入咗 {0} 隻：`n" = "Imported {0}:`n", "导入了 {0} 个：`n", "{0} 本取り込みました：`n"
  "`n`n失敗（原本個壓縮檔冇郁過）：`n" = "`n`nFailed (the original archive was not touched):`n", "`n`n失败（原压缩包没有动过）：`n", "`n`n失敗（元のアーカイブはそのままです）：`n"
  "`n`n新遊戲會喺遊戲庫等你檢查同確認先加入。" = "`n`nNew games wait in the library for you to review and confirm.", "`n`n新游戏会在游戏库等你检查并确认后才加入。", "`n`n新しいゲームはライブラリで確認してから追加されます。"
  '其他' = 'Other', '其他', 'その他'
  '加入' = 'Add', '加入', '追加'
  '加入遊戲' = 'Add game', '添加游戏', 'ゲームを追加'
  '揀遊戲嘅 exe（或者捷徑）' = "Pick the game's exe (or a shortcut)", '选择游戏的 exe（或快捷方式）', 'ゲームの exe（またはショートカット）を選択'
  '遊戲程式' = 'Game programs', '游戏程序', 'ゲームプログラム'
  '類別' = 'Category', '分类', 'カテゴリ'
  '顯示嘅名' = 'Name to show', '显示名称', '表示名'
  "加咗「{0}」入遊戲庫。`n想要封面：喺遊戲上面撳右鍵，揀「換封面」。" = "Added `"{0}`" to the library.`nFor a cover: right-click the game and choose `"Change cover`".", "已把「{0}」加入游戏库。`n想要封面：在游戏上点右键，选「更换封面」。", "「{0}」をライブラリに追加しました。`nカバーはゲームを右クリックして「カバーを変更」から設定できます。"
  '揀「{0}」嘅封面圖' = 'Pick a cover image for "{0}"', '选择「{0}」的封面图', '「{0}」のカバー画像を選択'
  '只支援 jpg / png / gif / webp。' = 'Only jpg / png / gif / webp are supported.', '只支持 jpg / png / gif / webp。', 'jpg / png / gif / webp のみ対応しています。'
  '圖片' = 'Images', '图片', '画像'
  '換封面' = 'Change cover', '更换封面', 'カバーを変更'
  '解除安裝' = 'Uninstall', '卸载', 'アンインストール'
  '放入回收筒' = 'Move to Recycle Bin', '移到回收站', 'ごみ箱へ移動'
  '刪唔到：{0}' = 'Could not delete: {0}', '删除失败：{0}', '削除できませんでした：{0}'
  "唔會刪呢個資料夾：`n{0}`n`n佢唔係單一遊戲嘅資料夾。" = "This folder will not be deleted:`n{0}`n`nIt is not a single game's folder.", "不会删除这个文件夹：`n{0}`n`n它不是单个游戏的文件夹。", "このフォルダーは削除しません：`n{0}`n`n1 本のゲームのフォルダーではありません。"
  "會將「{0}」成個資料夾放入回收筒：`n`n{1}`n大小：{2}`n`n存檔如果喺呢個資料夾入面，都會一齊刪。`n放入回收筒之後仲可以還原；太大嘅話 Windows 會再問你係咪直接刪除。" = "The whole folder of `"{0}`" will be moved to the Recycle Bin:`n`n{1}`nSize: {2}`n`nSaves inside this folder go with it.`nYou can restore it from the Recycle Bin; if it is too big, Windows will ask whether to delete it permanently.", "将把「{0}」整个文件夹移到回收站：`n`n{1}`n大小：{2}`n`n如果存档在这个文件夹里，也会一起删除。`n移到回收站后还可以还原；太大的话 Windows 会再问你是否直接删除。", "「{0}」のフォルダー全体をごみ箱に移動します：`n`n{1}`nサイズ：{2}`n`nこのフォルダー内のセーブデータも一緒に削除されます。`nごみ箱から元に戻せます。大きすぎる場合は Windows が完全に削除するか確認します。"
}
# T 'text {0}' value...  -> text in the chosen language with the values filled in
function T([string]$Key) {
  $s = $Key
  if ($null -ne $LangIx -and $I18N.ContainsKey($Key)) { $s = $I18N[$Key][$LangIx] }
  if ($args.Count) { $s = $s -f $args }
  return $s
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
function Add-UiButtons($form, [string]$OkText = (T '確定'), [string]$CancelText = (T '取消')) {
  $w = $form.ClientSize.Width; $y = $form.ClientSize.Height - 48
  $ok = New-UiButton $form $OkText ($w - 248) $y 'OK' -Primary; $no = New-UiButton $form $CancelText ($w - 128) $y 'Cancel'
  $form.AcceptButton = $ok; $form.CancelButton = $no
}
function Show-UiMessage([string]$Text, [string]$Title = (T '遊戲庫')) {
  $lines = [Math]::Max(2, ($Text -split "`n").Count); $f = New-UiForm $Title 520 ([Math]::Min(640, 150 + $lines * 22))
  $l = New-Object Windows.Forms.Label -Property @{ Text = $Text; Left = 18; Top = 50; Width = 470; Height = $f.ClientSize.Height - 110; ForeColor = $UI.Fg }
  $f.Controls.Add($l); $ok = New-UiButton $f (T '好') ($f.ClientSize.Width - 128) ($f.ClientSize.Height - 48) 'OK' -Primary; $f.AcceptButton = $ok
  [void]$f.ShowDialog()
}
function Confirm-Ui([string]$Text, [string]$Title, [string]$OkText = (T '確定')) {
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
  $cb = New-Object Windows.Forms.CheckBox -Property @{ Text = (T '用密碼解壓'); Left = 18; Top = 50; Width = 470; ForeColor = $UI.Fg; Checked = [bool]$saved.Count }
  $f.Controls.Add($cb)
  New-UiLabel $f ((T '密碼（可以揀用過嘅，或者打新嘅）') + $(if ($Note) { "  $Note" })) 82 | Out-Null
  $box = New-Object Windows.Forms.ComboBox -Property @{ Left = 18; Top = 106; Width = 470; BackColor = $UI.Panel; ForeColor = $UI.Fg; FlatStyle = 'Flat'; DropDownStyle = 'DropDown' }
  foreach ($p in $saved) { [void]$box.Items.Add($p) }; if ($saved.Count) { $box.SelectedIndex = 0 }
  $f.Controls.Add($box)
  $rem = New-Object Windows.Forms.CheckBox -Property @{ Text = (T '記住呢個密碼，下次可以直接揀'); Left = 18; Top = 142; Width = 470; ForeColor = $UI.Cyan; Checked = $true }
  $f.Controls.Add($rem)
  $sync = { $box.Enabled = $cb.Checked; $rem.Enabled = $cb.Checked }; $cb.Add_CheckedChanged($sync); & $sync
  Add-UiButtons $f (T '開始')
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
  $f.Controls.Add($list); Add-UiButtons $f (T '解壓揀咗嘅') (T '全部唔要')
  if ($f.ShowDialog() -ne 'OK') { return $null }
  return @($list.CheckedItems | ForEach-Object { [string]$_ })
}
