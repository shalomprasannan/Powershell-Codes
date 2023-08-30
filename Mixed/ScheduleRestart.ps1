$ScriptBlock = { 
    $RestartTime = (Get-Date "05:04 AM")
    $SleepTime = New-TimeSpan -Start (Get-Date) -End $RestartTime
    start-sleep -seconds $SleepTime.TotalSeconds
    #get-service -ComputerName crmw10d.m1.local
    Invoke-Command -ComputerName jp101.m1.local -ScriptBlock {try{restart-service jp1*}
    catch{start-service jp1*}}
    #Restart-Computer -ComputerName crmw10d.m1.local -Force
}
$Job = Start-Job -ScriptBlock $ScriptBlock