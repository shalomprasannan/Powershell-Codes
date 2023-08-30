function Copy-RemoteFiles{
    Param(
    [parameter (Mandatory=$true)][string]$Sourcepath,

    [parameter (Mandatory=$true)][string]$Destination,

    [parameter (Mandatory=$true)][string[]]$Computers
    )


    foreach($computername in $computers){
        #write-host "Copying on $computername" -ForegroundColor Green
        #$destination=$destination.Replace(":","$")
        #robocopy $sourcePath "\\$computername\$Destination" /Z /NP /NFL /NDL /NJH /NJS /R:2 /W:1
        invoke-command -computername "$computername.m1.local" -scriptblock {Copy-Item -Path '\\mocxen100\c$\users\ad_shalomp\Downloads\KB_March_28\2018-08 Update for Windows Server 2016 for x64-based Systems (KB4346087)\' -Destination 'C:\temp\newKB' -Force -recurse}

    }
}

## calling above Function
$machines=@("xavda108")
Copy-RemoteFiles -Sourcepath "\\10.150.60.92\c$\TrendMicro 2023 installers\TrendMicro agent version 20" -Destination "c:\temp\DSM 20" -Computers $machines


#below one is working.. but hardcode creds..

function Copy-FilesToRemoteServers {
    param (
        [string] $sourcePath,
        [string] $destination,
        [string[]] $computerNames
    )

    foreach ($computer in $computerNames) {
        $scriptBlock = {
            param ($source, $dest)

            net use Z: $source /user:ad_shalomp -1U3:uE8xPywepX/
            # Use robocopy to copy files with restartable mode
            robocopy Z:\ $dest /E /Z /MT:8 
            net use Z: /delete /y

        }

        Invoke-Command -ComputerName "$computer.m1.local" -ScriptBlock $scriptBlock -ArgumentList $sourcePath, $destination -Credential $cred
    }
}

# Example usage:
$sourcePath = "\\mercury102\c$\temp\copy"
$destination = "C:\temp\teams"
$computerNames = "XAVDA08","XAVDA09","XAVDA10","XAVDA01","MERCURY101","MERCURY102","MERCURY103"

Copy-FilesToRemoteServers -sourcePath $sourcePath -destination $destination -computerNames $computerNames
