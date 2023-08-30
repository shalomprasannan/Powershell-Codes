$computers = @("MOCEPMWB01","MOCEPMDB01","MERCURY002","MOC-SMSSurvey-VM","dsmdb01","fmsac001")
#$computers=Get-Content .\machines.txt
$programName = "Silverlight" # Replace with the name of the software to uninstall

$notReachable=@()
$notInstalled=@()
foreach ($computer in $computers) {
    $result=Invoke-Command -ComputerName "$computer.m1.local" -ScriptBlock {
        param($programName,
                $computer,
                $notInstalled)
        write-host "$(hostname)"
        $software = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$programName*" }
        if ($software) {
            $software.Uninstall()
            Write-host "$programName has been uninstalled on $computer."
            return $software
        } else {
            Write-host "$programName not found in installed programs on $computer."
            return "NotFound"
        }
    } -ArgumentList $programName,$computer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -AsJob

    If(!$result){
        Write-host "couldn't connect to $computer"
        $notReachable+=$computer
    }
    elseif($result -eq "NotFound"){
        $notInstalled+=$computer
    }
    else{
        $result
    }
}

#get-job | where state -eq "Failed"|select Location
#Get-Job |where state -eq "completed" | receive-job