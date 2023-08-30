$hostServers = "rocvcms11.m1.local","mocvcms11.m1.local"
foreach($hostServer in $hostServers){
    if(Connect-VIServer -server $hostServer -ErrorAction Ignore){
        write-host "Connected with $hostServer"   
    }
    else{
        write-host "couldn't connect to $hostServer"
    }
}

$machines = get-content c:\users\ad_shalomp\documents\scripts\machines.txt
$notInVMware = @()
#for taking new shanpshot

foreach($machine in $machines){
    if(Get-VM $machine -erroraction silentlycontinue){
        Get-Snapshot $machine| Remove-Snapshot -RunAsync -Confirm:$true
    }
    else{
        write-host "$Machine doesn't exist"
        $notInVMware+=$machine
    }
}