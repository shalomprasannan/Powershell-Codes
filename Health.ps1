$machines = Get-content .\servers.txt
$color="white"

$Array=@()
foreach($machine in $machines){
    if(Test-connection $machine -Count 1 -Quiet){
        $reachable =  "Reachable"
        try{
            $data = Invoke-command -ComputerName "$machine.m1.local" -ErrorAction SilentlyContinue -ScriptBlock {
                (Get-wmiobject -Class Win32_OperatingSystem).LastBootUpTime }
            $now = Get-Date
            $timeDiff = $now - [System.Management.ManagementDateTimeConverter]::ToDateTime($data)
            $data = $timeDiff.Days
        }
        catch{
            $data = "No winRM"
        }
    
    }
    else{
        $reachable ="unReachable"
    }
    $object = [pscustomobject]@{
    Machine = $machine
    Reachable = $reachable
    BootTime = $data
    }
    $object
    $data=""
    $machine=""
    $reachable=""
    $Array+=$object

}
$Array|Export-csv -path .\output.txt