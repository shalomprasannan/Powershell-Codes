#Add-Type -AssemblyName PresentationFramework
#Add-Type -AssemblyName PresentationCore
#Add-Type -AssemblyName WindowsBase

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

    
    start-sleep -Seconds 5

    $screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
    $bmp.Save("C:\users\ad_shalomp\documents\$env:COMPUTERNAME $imagename.png")
    $graphics.Dispose()
    Stop-Process -Id $process.Id
}



control.exe /name Microsoft.WindowsUpdate /page pageUpdateHistory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Wait for the window to open
Start-Sleep -Seconds 1

[System.Windows.Forms.SendKeys]::SendWait("%")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("x")

cmdrunner "updateHistory"



# Wait for the window to open
Start-Sleep -Seconds 5

# Simulate keystrokes to navigate to the "View installed updates" section
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

# Wait for the section to load
Start-Sleep -Seconds 10
cmdrunner "Installed_updates"
# Take a screenshot


$sourcePath = "C:\users\ad_shalomp\documents\$env:COMPUTERNAME installed_updates.png"
$destinationPath = "\\mercury102\users\ad_shalomp\documents\UAR\$env:COMPUTERNAME Installed_Updates.png"
Copy-Item -Path $sourcePath -Destination $destinationPath

$sourcePath = "C:\users\ad_shalomp\documents\$env:COMPUTERNAME UpdateHistory.png"
$destinationPath = "\\mercury102\users\ad_shalomp\documents\UAR\$env:COMPUTERNAME UpdateHistory.png"
Copy-Item -Path $sourcePath -Destination $destinationPath
if (-not $appwiz.HasExited) {
    $appwiz.CloseMainWindow()
}

