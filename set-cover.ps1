# Pick an image and use it as a game's cover: copied to covers\<game name>.<ext>, replacing the old cover.
param([Parameter(Mandatory)][string]$Name, [string]$Image)  # -Image: skip the dialog (testing)
. "$PSScriptRoot\ui.ps1"
$covers = Join-Path $PSScriptRoot 'covers'
if (-not $Image) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = T '揀「{0}」嘅封面圖' $Name
  $dlg.Filter = (T '圖片') + '|*.jpg;*.jpeg;*.png;*.gif;*.webp|' + (T '全部') + '|*.*'
  if ($dlg.ShowDialog() -ne 'OK') { exit 0 }
  $Image = $dlg.FileName
}
$ext = [IO.Path]::GetExtension($Image).ToLower()
if ($ext -notin '.jpg', '.jpeg', '.png', '.gif', '.webp') { Show-UiMessage (T '只支援 jpg / png / gif / webp。') (T '換封面'); exit 1 }
New-Item -ItemType Directory -Force $covers | Out-Null
$dest = Join-Path $covers "$Name$ext"
Copy-Item -LiteralPath $Image $dest -Force
# the launcher picks the first match by extension, so drop this game's covers in other formats
foreach ($e in '.jpg', '.jpeg', '.png', '.gif', '.webp') { $o = Join-Path $covers "$Name$e"; if ($e -ne $ext -and (Test-Path -LiteralPath $o)) { Remove-Item -LiteralPath $o } }
