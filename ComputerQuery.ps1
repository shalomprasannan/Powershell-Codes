function Get-ComputerInfo{

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string]$ComputerName = ""
    )


        try {
            $ipAddress = Resolve-DnsName "$computerName" -Type A | select -ExpandProperty IPAddress
            $os = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $ComputerName
            $model=(Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName).Model 
            $serialNo=Get-WmiObject -Class Win32_BIOS -ComputerName $ComputerName | Select -ExpandProperty SerialNumber
            $loggedOnUsers = (quser /server:"$ComputerName" | Select-Object -Skip 1 | ForEach-Object { 
                                    if(($_ -split '\s+')[0][0] -eq '>'){
                                    ($_ -split '\s+')[0].substring(1) }
                                    else{
                                    ($_ -split '\s+')[1] 
                                    }})
            $servicePack = $os.ServicePackMajorVersion
            $buildNumber = $os.BuildNumber
            $lastBootTime = $os.LastBootUpTime
            $computerName = $os.CSName
        }
        catch {
            $errors="couldn't connect to the server"
        }

     return [PSCustomObject]@{
         ComputerName = $computerName
         IPAddress = $ipAddress
         OperatingSystem = $os.Caption
         ServicePack = $servicePack
         Build = $buildNumber
         LastBootTime = $lastBootTime
         Model=$model
         SerialNo=$serialNo
         LoggedOnUsers=$loggedOnUsers
         Error=$errors
     }

}