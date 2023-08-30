#$machines=@("XADB01", "XADB01U", "XADDC01", "XADDC02", "XADDC101", "XADDC101U", "XADDC102", "XADIR01", "XALIC01", "XASFR01", "XASFR02", "XASFR101", "XASFR101U", "XASFR102", "XAVDA01", "XAVDA02", "XAVDA03", "XAVDA04", "XAVDA05", "XAVDA06", "XAVDA07", "XAVDA08", "XAVDA09", "XAVDA10", "XAVDA101", "XAVDA101U", "XAVDA102", "XAVDA102U", "XAVDA103", "XAVDA104", "XAVDA104U", "XAVDA105", "XAVDA106", "XAVDA107", "XAVDA108", "XAVDA109", "XAVDA11", "XAVDA110")
$machines=get-content .\machines.txt

$connecting = @()
$notConnecting = @()
$notPinging = @()

foreach ($machine in $machines) {
    $computerName = "$machine.m1.local"
    if (Test-Connection $machine -Count 1 -Quiet) {
        $result = Invoke-Command -ComputerName $computerName -ErrorAction SilentlyContinue -ScriptBlock {
            hostname
        }
        if($result){
            "$machine`tConnected"
            $connecting += $result
        }
        else{
            "$machine`tNot Connected"
            $notConnecting += $machine
        }
    } elseif(!(Test-Connection $machine -Count 8 -Quiet)) {
        
        "$machine`tNot Pinging"
        $notPinging += $machine
    }
}
"connecting : $connecting"