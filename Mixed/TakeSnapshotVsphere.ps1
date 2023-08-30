$hostServers = "rocvcms11.m1.local","mocvcms11.m1.local"
foreach($hostServer in $hostServers){
    if(Connect-VIServer -server $hostServer -ErrorAction Ignore){
        write-host "Connected with $hostServer"   
    }
    else{
        write-host "couldn't connect to $hostServer"
    }
}


$name="13th July"
$description="..."
$machines = get-content c:\users\ad_shalomp\documents\scripts\machines1.txt
$notInVMware = @()
#for taking new snapshot

foreach($machine in $machines){
    if(Get-VM $machine -erroraction silentlycontinue){
        #get-snapshot -VM $machine|Remove-Snapshot -RunAsync -Confirm:$true
        New-Snapshot $machine -Name $name -Description $description -RunAsync
    }
    else{
        write-host "$Machine doesn't exist"
        $notInVMware+=$machine
    }
}