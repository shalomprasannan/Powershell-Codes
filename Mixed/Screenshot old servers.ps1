Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

Add-Type -Namespace PInvoke.Win32.User32 -Name WindowUtils `
    -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
'@

$process=@{}
function cmdRunner(){
param(
        [string]$imagename
    )

Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public static class User32 {
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    }
"@

$process = Start-Process cmd.exe -ArgumentList "/K hostname" -PassThru
Start-Sleep -Milliseconds 500
$win = (Get-Process cmd | Where-Object {$_.Id -eq $process.Id}).MainWindowHandle
[PInvoke.Win32.User32.WindowUtils]::MoveWindow([IntPtr]$win, 0, 500, 400, 400, $true)

start-sleep -Seconds 5

$screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
$bmp.Save("\\mercury102\users\ad_shalomp\documents\UAR\$env:COMPUTERNAME $imagename.png")
$graphics.Dispose()
Stop-Process -Id $process.Id
}



start-process control.exe -argumentlist "/name Microsoft.WindowsUpdate /page pageUpdateHistory" -wait

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Wait for the window to open
Start-Sleep -Seconds 1

[System.Windows.Forms.SendKeys]::SendWait("%")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("x")

cmdrunner "updateHistory"


[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

# Wait for the section to load
start-sleep -seconds 2
[System.Windows.Forms.SendKeys]::SendWait("% ")
start-sleep -seconds 1
[System.Windows.Forms.SendKeys]::SendWait("n")
start-sleep -seconds 2
cmdrunner "Installed_updates"
# Take a screenshot