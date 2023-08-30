Start-Transcript -Path C:\Temp\scriptlogs.txt -Append
write-output "couldn't connect to $"
Add-PSSnapin citrix.*
$VCHosts = "rocvcms11.m1.local","mocvcms11.m1.local"
foreach($VCHost in $VCHosts){
    if(Connect-VIServer -server $VCHost -ErrorAction Ignore){
        write-output "Connected with $VCHost"   
    }
    else{
        write-output "couldn't connect to $VCHost"
    }
}
$machines=Get-BrokerDesktop -AdminAddress xaddc01 -RegistrationState Unregistered | select machinename, registrationstate, associatedusernames|where {$_.associatedUserNames.length -lt 1}
$restartedVM=@()
$downVM=@()
foreach($machine in $machines){
    $computerName = $machine.machinename.Replace("M1\","")
    write-output "Testing Conection $computername"
    if(Test-connection $computerName -Count 1 -ErrorAction SilentlyContinue){
        write-output "Checking WinRM"
        if(Invoke-command -ComputerName "$computername.m1.local" -ErrorAction SilentlyContinue -ScriptBlock{hostname}){
            write-output "Powershell working : Not Restarted"
            continue
            }
        }
    write-output "getting VM info"
    $vm=get-vm $computerName -ErrorAction SilentlyContinue
    if($vm){
        "Restarting VM"
        $restartedVM+=$computerName
        Restart-VM $computername -Confirm:$false
    }
    else{
        $downVM+=$computerName
        "$computername Not available on VMWare"
    }
}

if($restartedVM -or $downVM){
    $body= @"
    Below machines are Rebooted
    $RestartedVM

    Below machines are down, Please restart manually
    $downVM
"@

    Send-MailMessage -Verbose -SmtpServer "intmx.m1.com.sg"`
                 -Port "25"`
                 -From "SystemAlert@m1.com.sg" `
                 -To "in_shalomp@m1.com.sg" `
                 -cc "DL_Wintel@m1.com.sg" `
                 -Subject "Alert : Citrix VDA Down" `
                 -Body $body
}

foreach($VCHost in $VCHosts){
    Disconnect-VIServer -server $VCHost -Confirm:$false
    write-output "Disconnected with $VCHost"   
}

Stop-Transcript