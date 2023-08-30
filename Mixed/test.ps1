$pages=@("Users", "Admins", "RDP", "windows update", "System info")

$main_0=start-process lusrmgr.msc -passthru

#perform pause here and continue if a button is clicked
start-sleep -seconds 10

$temp_0=start-process cmd.exe -argumentlist "/K net localgroup users" -passthru
Start-Sleep -Milliseconds 500
$temp_win = (Get-Process cmd | Where-Object {$_.Id -eq $temp_0.Id}).MainWindowHandle
[PInvoke.Win32.User32.WindowUtils]::MoveWindow([IntPtr]$temp_win, 0, 200, 400, 400, $true)
start-sleep -Seconds 1
$screenshot_btn.PerformClick()
start-sleep -seconds 2
stop-process -id $temp_0.Id

start-sleep -seconds 10

$temp_1=start-process cmd.exe -argumentlist "/K net localgroup administrators" -passthru
Start-Sleep -Milliseconds 500
$temp_win = (Get-Process cmd | Where-Object {$_.Id -eq $temp_1.Id}).MainWindowHandle
[PInvoke.Win32.User32.WindowUtils]::MoveWindow([IntPtr]$temp_win, 0, 200, 400, 400, $true)
start-sleep -Seconds 1
$screenshot_btn.PerformClick()
start-sleep -seconds 2
stop-process -id $temp_1.Id

start-sleep -seconds 10


$temp_2=Start-Process cmd.exe -ArgumentList "/K net localgroup ""Remote Desktop Users"""-passthru
Start-Sleep -Milliseconds 500
$temp_win = (Get-Process cmd | Where-Object {$_.Id -eq $temp_2.Id}).MainWindowHandle
[PInvoke.Win32.User32.WindowUtils]::MoveWindow([IntPtr]$temp_win, 0, 200, 400, 400, $true)
start-sleep -Seconds 1
$screenshot_btn.PerformClick()
start-sleep -seconds 2
stop-process -id $temp_2.Id
stop-process -id $main_0.Id

start-sleep -seconds 2


$controlpanel=start-process control.exe -argumentlist "/name Microsoft.WindowsUpdate /page pageUpdateHistory" -wait
start-sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait("%")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("x")
start-sleep -Seconds 1
$screenshot_btn.PerformClick()
start-sleep -Seconds 1
stop-process -id $controlpanel.Id

start-sleep -seconds 2


# Start the Control Panel with the System Information page
$sysinfo=Start-Process control.exe -ArgumentList "/name Microsoft.System" -Wait
start-sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait("%")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("x")
$sysdm=start-process sysdm.cpl 
start-sleep -Seconds 5
$screenshot_btn.PerformClick()
start-sleep -Seconds 1
stop-process -id $controlpanel.Id
