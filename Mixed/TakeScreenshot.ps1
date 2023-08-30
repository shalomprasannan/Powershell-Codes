$script={
# Launch control.exe to open the Windows Update window
control.exe /name Microsoft.WindowsUpdate /page pageUpdateHistory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Wait for the window to open
Start-Sleep -Seconds 1

[System.Windows.Forms.SendKeys]::SendWait("%")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("x")

Start-Sleep -Seconds 1

$screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
$bmp.Save("\\mercury102\users\ad_shalomp\documents\$env:COMPUTERNAME UpdateHistory.png")
$graphics.Dispose()

# Wait for the window to open
Start-Sleep -Seconds 5

# Simulate keystrokes to navigate to the "View installed updates" section
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")


# Wait for the section to load
Start-Sleep -Seconds 180

# Take a screenshot

$screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
$bmp.Save("C:\users\ad_shalomp\documents\$env:COMPUTERNAME installed_updates.png")
$graphics.Dispose()

if (-not $appwiz.HasExited) {
    $appwiz.CloseMainWindow()
}
}

$session=new-pssession -ComputerName crm08.m1.local

Invoke-command -session $session -ScriptBlock $script