$hostings = "rocvcms11.m1.local"
foreach($hosts in $hostings){
    if(Connect-VIServer -server $hosts -ErrorAction Ignore){
        write-host "Connected with $hosts"   
    }
    else{
        write-host "couldn't connect to $hosts"
    }
}


$machines = get-content c:\users\ad_shalomp\documents\scripts\machines.txt

#for taking new shanpshot

foreach($machine in $machines){
    if(!(Get-VM $machine -erroraction silentlycontinue)){
        New-Snapshot $machine -Name Patching -Description "March 2nd batch"
    }
    else{
        write-host "$Machine doesn't exist"
    }
}


#for Removing Snapshot
$snapshots = get-snapshot -vm * -Name Patching

$time = get-date
$time.AddDays(-7)
$snapshots | where created -lt $time.AddDays() #|  Remove-snapshot -runasync

foreach($machine in $machines){
    get-snapshot -vm $machine | Remove-snapshot -runasync
}