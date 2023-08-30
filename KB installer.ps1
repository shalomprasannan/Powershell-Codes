$sourcePath="C:\Users\ad_shalomp\Downloads\KB_March_28\"

function Copy-KBs{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Kbs
    )

    foreach($kb in $kbs){
        
        if(!(test-path "$sourcePath\*$kb*")){
            write-host "$kb no such path" -ForegroundColor red
            continue
        }
        resolve-path "$sourcePath*$kb*"
        $fullpath = resolve-path "$sourcePath*$kb*"
        $filePath = Get-ChildItem -Path $fullPath | Select-Object -ExpandProperty FullName
        $fileName = Split-Path -Leaf $filePath
        write-host "Copying $Kb to $computername" -ForegroundColor Green
        robocopy $fullPath "\\$computername\c$\temp\kb\" $filename /Z /NP /NFL /NDL /NJH /NJS
    }
}

function Install-KBs{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Kbs
    )
    #Copy-KBs -ComputerName $ComputerName -Kbs $Kbs

    $session = New-PSSession -ComputerName "$ComputerName.m1.local"

    foreach($kb in $kbs){
        if(!(test-path "$sourcePath*$kb*")){
        write-host "$kb no such path"
        continue
        }
        $filePath = Get-ChildItem -Path $sourcePath -Filter "*$Kb*" | Select-Object -ExpandProperty FullName
        $fileName = Split-Path -Leaf $filePath
        $filename
        $ext= $fileName.Split(".")[-1]
        if($ext -eq "exe"){
            $installResult = Invoke-Command -ComputerName "$ComputerName.m1.local" -ScriptBlock {
                param($filename)
                hostname
                $process = Start-Process -FilePath "c:\temp\$filename" -ArgumentList "/quiet /norestart" 
                if ($process.ExitCode -ne 0) {
                    return $process.ExitCode
                }
            } -ArgumentList $filename
            $installResult
            if ($installResult -ne $null) {
                write-host "Error: Failed to install update $fileName on $ComputerName. Exit code: $installResult"
            }
        }
        else{
            $installResult = Invoke-Command -Session $session -ScriptBlock {
            param($filename)
            Start-Process -FilePath "wusa.exe" -ArgumentList "C:\temp\$filename /quiet /norestart"
            }-ArgumentList $filename
            if ($installResult.ExitCode -eq 0) {
                    Write-Host "Update $Kb installed successfully on $ComputerName."
                }
                else {
                    Write-Host "Failed to install update $Kb on $ComputerName. Exit code: $($installResult.ExitCode)"
                }
            }

        #Invoke-Command -ComputerName "$ComputerName.m1.local" -ScriptBlock{
                #param($kb)
                #check from event viewer
                #Get-WinEvent -LogName Application -maxEvents 50 | where {($_.id -eq "1022")-and($_.message -like "*$kb*")}} -argumentlist $kb

        }
}


#check from event viewer
#Get-WinEvent -LogName Application -maxEvents 50 | where id -eq "1022"



===============================================================
$computername="sntlgc01d.m1.local"
$sourcePath="C:\Users\ad_shalomp\Downloads\Tenable\kb\"

function Copy-KBs{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Kbs
    )
    $failed=@()
    $success=@()
    foreach($kb in $kbs){
        write-host "$sourcePath*$kb*"
        if(!(test-path "$sourcePath*$kb*")){
        write-host "$kb no such path" -ForegroundColor red
        $failed+="$kb"
        continue
        }
        $filePath = Get-ChildItem -Path $sourcePath -Filter "*$Kb*" | Select-Object -ExpandProperty FullName
        $fileName = Split-Path -Leaf $filePath
        write-host "Copying $Kb to $computername" -ForegroundColor Green
        robocopy $sourcePath "\\$computername\c$\temp" $filename /Z /NP /NFL /NDL /NJH /NJS
        $success+=$kb
    }
    return $myObject = [PSCustomObject]@{
    Success     = $success
    Failed = $failed
    }
}


$computername="sntlgc01d.m1.local"
$session = New-PSSession -ComputerName "$computername"
#$kbs=@("KB4495625","KB4495624")
$kbs=@("KB4506993","KB4506955","KB4514354","KB4532933","KB4552926","KB4565628","KB4569746","KB4576479","KB5013625","KB5022838","KB5022503")

#$status = Copy-KBs $ComputerName $kbs
foreach($kb in $kbs){
    invoke-command -Session $session -ScriptBlock{
        param($kb)
        $file = resolve-path "c:\temp\*$kb*"
        write-host "Installing $file"
        Start-Process -FilePath "wusa.exe" -ArgumentList "$file /quiet /norestart /wait" -Wait 
    } -ArgumentList $kb
}

