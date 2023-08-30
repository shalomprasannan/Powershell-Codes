get-childitem -path c:\temp\kb |foreach{
#
$_.FullName
    if($_.Extension -eq ".msu"){
        Start-Process -FilePath "wusa.exe" -ArgumentList $_.FullName," /quiet /norestart" -Wait
    }
    else{
        start-process $_.FullName -ArgumentList "/norestart /silent /q" -wait
    }
}


$InstalledKbs=@()
$notInstalledKbs=@()
$paths=get-childitem -path c:\temp\kb
foreach($path in $paths){
    $kb=$path.name|select-string -Pattern "[4,5]\d{6}" | Foreach-Object {$_.Matches.Value}
    $check=get-hotfix -id "kb$kb" -ErrorAction SilentlyContinue
    if($check){
        $check
        $installedKbs+=$kb
    }
    else{
        $notInstalledKbs+=$kb
    }
}
#Write-host $InstalledKbs -ForegroundColor Green
Write-host $notInstalledKbs -ForegroundColor red
