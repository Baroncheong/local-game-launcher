# Uninstall a game: after confirmation, move its folder to the Recycle Bin (Windows may ask before deleting
# permanently if the folder is too big for the bin). Exit code 0 = removed, 1 = cancelled or refused.
param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][string]$Folder, [string]$Protect = '')  # Protect: "|"-separated game folders that must never be deleted
. "$PSScriptRoot\ui.ps1"
Add-Type -AssemblyName Microsoft.VisualBasic
$full = [IO.Path]::GetFullPath($Folder).TrimEnd('\')
$deny = @([IO.Path]::GetPathRoot($full).TrimEnd('\'), $env:SystemRoot, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:USERPROFILE, "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads", "$env:USERPROFILE\Documents", $PSScriptRoot) +
        @($Protect -split '\|' | Where-Object { $_ }) | ForEach-Object { $_.TrimEnd('\') }
if (-not (Test-Path -LiteralPath $full -PathType Container) -or ($deny -contains $full)) {
  Show-UiMessage "唔會刪呢個資料夾：`n$full`n`n佢唔係單一遊戲嘅資料夾。" '解除安裝'; exit 1
}
$size = (Get-ChildItem -LiteralPath $full -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
$gb = '{0:N2} GB' -f ($size / 1GB)
if (-not (Confirm-Ui "會將「$Name」成個資料夾放入回收筒：`n`n$full`n大小：$gb`n`n存檔如果喺呢個資料夾入面，都會一齊刪。`n放入回收筒之後仲可以還原；太大嘅話 Windows 會再問你係咪直接刪除。" '解除安裝' '放入回收筒')) { exit 1 }
try {
  [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($full, 'OnlyErrorDialogs', 'SendToRecycleBin')
} catch { Show-UiMessage "刪唔到：$($_.Exception.Message)" '解除安裝'; exit 1 }
if (Test-Path -LiteralPath $full) { exit 1 }   # user cancelled Windows' own prompt
exit 0
