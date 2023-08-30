
$notavailable=@()
$output=@()

import-csv -Path C:\Users\ad_shalomp\Documents\Book1.csv| group-object hostname |foreach{
$vars = $_.group|select synopsis, solution, description, "plugin output","plugin name"
$object=@{}
$string = ""
$machineName=$_.group."NetBIOS Name"
foreach($obj in $vars){
    foreach($ob in $obj.psobject.Properties){
        $string+=$ob.Value
    }
}
$object.machineName=$_.name
$object.string=$string
$output+=$object

}

$achieved=@()
foreach($machine in $output){
    $kbs=$machine.string| Select-String -Pattern "[4,5]\d{6}" -AllMatches|Foreach-Object {$_.Matches.Value}| Select-Object -Unique
    $temp = [PSCustomObject]@{
        Name = $machine.machineName
        Kbs = $kbs
    }
    $achieved+=$temp

}

#$achieved #| select -first 3 -ExpandProperty kbs
$achieved|foreach{
write-host "$($_.Name)" -ForegroundColor Green
Write-host "$($_.kbs)"
}

#to exclude already downloaded KBs
$kbs=$achieved.kbs|sort -Unique
$notinInv=@()
foreach($kb in $kbs){
    if(!(test-path "C:\Users\ad_shalomp\Downloads\KB_March_28\*$kb*")){
        $notinInv+=$kb
    }
}

<#
function Copy-KBs{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Kbs
    )
    $sourcePath="C:\Users\ad_shalomp\Downloads\KB_March_28"
    foreach($kb in $kbs){
        
        if(!(test-path "$sourcePath\*$kb*")){
            write-host "$kb no such path" -ForegroundColor red
            $notfound+=$kb
            continue
        }
        $fullpath = resolve-path "$sourcePath\*$kb*"
        $filePath = Get-ChildItem -Path $fullPath | Select-Object -ExpandProperty FullName
        $fileName = Split-Path -Leaf $filePath
        write-host "Copying $Kb to $computername" -ForegroundColor Green
        $job = Start-Job -ScriptBlock { 
            robocopy $args[0] $args[1] $args[2] /Z /NP /NFL /NDL /NJH /NJS /XO 
            }-ArgumentList $fullPath, "\\$computername\c$\temp\June_kb\", $fileName
    }
}
#>
$global:notFound=@()
function Copy-Kbs{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Kbs
    )
    Invoke-Command -ComputerName "$computername.m1.local" -ScriptBlock{New-Item -ItemType Directory -Path C:\temp\newKB\|out-null}
    $sourcePath="C:\Users\ad_shalomp\Downloads\KB_March_28"
    $patharray=@()
    foreach($kb in $kbs){
        if(!(test-path "$sourcePath\*$kb*")){
                write-host "$kb no such path" -ForegroundColor red
                $notfound+=$kb#some issues
                continue
            }
        $fullpath = resolve-path "$sourcePath\*$kb*"
        $patharray+=Get-ChildItem -Path $fullPath | Select-Object -ExpandProperty FullName
    }
    write-host "copying to $computername"
    $job = Start-Job -ScriptBlock { 
        $b = New-PSSession -computername "$($args[0]).m1.local"
        Copy-Item -toSession $b -path $args[1] -Destination 'C:\temp\newKB' -Force -recurse
        } -ArgumentList $ComputerName,$patharray

}

function Install-Kbs{
    foreach($machine in $($achieved|where name -eq "M_OFFC_NTSRV18")){
        if($machine.Name -and $machine.kbs){
            copy-kbs -computername $machine.Name -Kbs $machine.kbs
        }    
        Get-Job | Where-Object { $_.State -eq "Completed" } | Remove-Job
    }
    
}

function