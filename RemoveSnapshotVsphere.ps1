$hostServers = "rocvcms11.m1.local","mocvcms11.m1.local"
foreach($hostServer in $hostServers){
    if(Connect-VIServer -server $hostServer -ErrorAction Ignore){
        write-host "Connected with $hostServer"   
    }
    else{
        write-host "couldn't connect to $hostServer"
    }
}

$machines = get-content X:\PureStorage\VSphere\machines.txt
$notInVMware = @()
#for taking new shanpshot

foreach($machine in $machines){
    $machine
    if(Get-VM $machine -erroraction silentlycontinue){
        Get-Snapshot $machine | Remove-Snapshot -RunAsync -Confirm:$false
    }
    else{
        write-host "$Machine doesn't exist"
        $notInVMware+=$machine
    }
}

#Removing Snapshots older than 6 days and size less than 1TB
#$snapshots=get-snapshot -vm * |where created -lt (get-date).AddDays(-4)|where SizeGB -lt 1024|where sizeGB -ne 0|remove-snapshot -RunAsync -Confirm:$false 
