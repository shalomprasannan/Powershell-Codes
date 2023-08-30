$InstalledKbs=@()
$notInstalledKbs=@()
$paths=get-childitem -path c:\temp\june_kb
foreach($path in $paths){
    $kb=$path.name|select-string -Pattern "[4,5]\d{6}" | Foreach-Object {$_.Matches.Value}
    $check=get-hotfix -id "kb$kb" -ErrorAction SilentlyContinue
    if($check){
        write-host "$kb is already installed" -ForegroundColor Green
        write-host "Removing $kb from c:\temp\kb" -ForegroundColor Green
        $installedKbs+=$kb
        remove-item -Path $path.fullname
        }

    else{
        $notInstalledKbs+=$kb
            if($path.Extension -eq ".msu"){
                "installing $Kb"
                Start-Process -FilePath "wusa.exe" -ArgumentList $path.FullName," /quiet /norestart" -Wait
            }
            elseif($path.Extension -eq ".exe"){
                #start-process $path.FullName -ArgumentList "/norestart /silent /q" -wait
            }
            else{
                write-host "$($path.name) should be installed Manually..!" -ForegroundColor Red
            }
        }

    $check=get-hotfix -id "kb$kb" -ErrorAction SilentlyContinue
    if($check){
        $check
        $installedKbs+=$kb
        remove-item -Path $path.fullname -ErrorAction SilentlyContinue
        }
}
#Write-host $InstalledKbs -ForegroundColor Green
Write-host $notInstalledKbs -ForegroundColor red
