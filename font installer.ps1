$Path="\\mocsccm02\apps\Apps Deployment\M1Fonts"
$Fonts = get-childitem $Path\*.ttf

$installShell = New-Object -ComObject Shell.Application
$installLocation = $installShell.Namespace(0x14)
$installedFonts = @(Get-ChildItem c:\windows\fonts | Where-Object {$_.PSIsContainer -eq $false} | Select-Object basename)
foreach($Font in $Fonts) {
   $installed=$installedfonts|where basename -eq $font.basename
   if($font.BaseName -ne $installed.Basename){
       write-host "Installing $($font.basename)" -ForegroundColor green
       $installLocation.CopyHere($Font.fullname)
   }
}
