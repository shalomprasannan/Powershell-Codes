#open whatever you want
#$controlpanel=start-process control.exe -argumentlist "/name Microsoft.WindowsUpdate /page pageUpdateHistory" -wait
#save where you want
$savepath = "\\mercury102\users\ad_shalomp\documents\UAR"
#maximize what was opened
start-sleep 0.5
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#[System.Windows.Forms.SendKeys]::SendWait("%")
#[System.Windows.Forms.SendKeys]::SendWait(" ")
#[System.Windows.Forms.SendKeys]::SendWait("x")
#image names
$pages=@("Users", "Admins", "RDP", "windows update", "System info")
$screenHeight=240
$nextflag=0
$SScounter=0


Add-Type -AssemblyName System.Windows.Forms
Add-Type -Namespace PInvoke.Win32.User32 -Name WindowUtils `
    -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
'@

function Add-UI {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('Button','TextBox')]
        [string]$componentType,
        
        [Parameter(Mandatory=$true)]
        [string]$text,
        
        [Parameter()]
        [int]$width = 100,
        
        [Parameter()]
        [int]$height = 30
    )
    Add-Type -AssemblyName System.Windows.Forms

    $control = New-Object "System.Windows.Forms.$componentType"
    $control.Size = New-Object System.Drawing.Size($width, $height)
    $locationX = 20
    $locationY = $form.Controls.Count * ($height + 5) + 50
    $screenheight=$locationY
    $control.Location = New-Object System.Drawing.Point($locationX, $locationY)
    $control.Text = $text
    
    return $control
}


# Create a new form
$form = New-Object System.Windows.Forms.Form
$form.Text = "ScreenShot"
#$form.Size = New-Object System.Drawing.Size(160, 240)
$form.TopMost = $true
#$form.ControlBox = $false  # Disable the control box
$form.MaximizeBox = $false  # Disable the maximize button
$form.MinimizeBox = $false 
$form.StartPosition = "Manual"
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$x = $screen.Bounds.Right - $form.Width
$y = $screen.Bounds.Top
$form.Location = New-Object System.Drawing.Point($x, $y)



#$form.FormBorderStyle="None"
$form.margin="0,0,0,0"

# Create a text field
$textField = Add-UI -componentType TextBox -text $pages[$SScounter]
$form.Controls.Add($textField)

$SaveField = Add-UI -componentType TextBox -text $savepath
$form.Controls.Add($SaveField)

$CustomRun = Add-UI -componentType Button -text "Custom Script"
$form.Controls.Add($CustomRun)


$Screenshot_btn = Add-UI -componentType Button -text "ScreenShot"
$form.Controls.Add($Screenshot_btn)

$button = Add-UI -componentType Button -text "Close"
$form.Controls.Add($button)

$logoff = Add-UI -componentType Button -text "Logoff"
$form.Controls.Add($logoff)

$form.Size = New-Object System.Drawing.Size(160, $($ScreenHeight+50))

# Define a function to handle the button click event
$button_Click = {
    #stop-process -id $controlpanel.Id
    $form.Close()
}

$logoff_click={
    shutdown /l /f
}

$Screenshot_Click = {
    $form.windowstate="Minimized"
    Start-Sleep -Seconds 0.5

    $process = Start-Process cmd.exe -ArgumentList "/K hostname" -PassThru
    Start-Sleep -Milliseconds 1000
    $win = (Get-Process cmd | Where-Object {$_.Id -eq $process.Id}).MainWindowHandle
    [PInvoke.Win32.User32.WindowUtils]::MoveWindow([IntPtr]$win, 0, 500, 400, 400, $true)
    start-sleep -Seconds 1
    $screenshot = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bmp = New-Object System.Drawing.Bitmap $screenshot.Width, $screenshot.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($screenshot.Location, [System.Drawing.Point]::Empty, $screenshot.Size)
    $bmp.Save("$savepath\$env:COMPUTERNAME $($textField.Text).png")
    $graphics.Dispose()
    Stop-Process -Id $process.Id
    $form.windowstate="Normal"
    $SScounter++
    $textfield.text=$pages[$SSCounter]
}

$CustomScript={
    $CsScript=get-content -Raw \\mercury102\users\ad_shalomp\documents\UAR\customscript.ps1
    Invoke-Expression $CsScript
}

$next_click={
    $nextflag=1
}

# Associate the function with the button's Click event
#$button.Add_Click($button_Click)
$screenshot_btn.Add_Click($Screenshot_click)
$CustomRun.Add_Click($CustomScript)
$logoff.Add_Click($logoff_click)
# Show the form
$form.ShowDialog() | Out-Null