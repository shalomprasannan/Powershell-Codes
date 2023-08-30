$computers=@("BILLIMG01N","RARPT02")
#$windowsSpeculative = get-content .\registries\windowsSpeculative.reg
$TLS_Recommended=get-content ".\registries\ssl3.0disable.reg"
foreach($computer in $computers){
    Invoke-Command -ComputerName "$computer.m1.local" -ScriptBlock{
        hostname
        $timestamp=get-date -Format "dd-MM"
        reg export HKLM "C:\users\ad_shalomp\documents\Backup-$timestamp.reg" /y
        start-sleep -Seconds 5

        #$using:windowsSpeculative | Out-File c:\users\ad_shalomp\documents\windowsSpeculative.reg
        $using:TLS_Recommended | Out-File c:\users\ad_shalomp\documents\TLS_Recommended.reg
        #regedit /s c:\users\ad_shalomp\documents\windowsSpeculative.reg
        regedit /s c:\users\ad_shalomp\documents\TLS_Recommended.reg

    }
}