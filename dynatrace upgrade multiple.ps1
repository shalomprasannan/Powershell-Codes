$machines = @("DASW03.m1.local","DASW04.m1.local","CRM09.m1.local","CRM11.m1.local","CRM12.m1.local","CRM13.m1.local","CRM14.m1.local","CRM24.m1.local","CRM10.m1.local","CRM23.m1.local")
$machines=@("CRM10.m1.local","dasw03.m1.local")

foreach ($machine in $machines)
{
    Invoke-Command -ComputerName "$machine" -ScriptBlock {
    if(get-service "Dynatrace OneAgent"){
        "Stopping Services"
        stop-service "Dynatrace OneAgent"
        "Searching App"
        #wmic product where name='Dynatrace OneAgent' call uninstall /nointeractive
        $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like "Dynatrace oneAgent"}
        "Uninstalling App"
        $Myapp.uninstall()
        }
    else{"Not installed"}
    "Removing Directory"
    rm C:\ProgramData\dynatrace -r
    }
}
#restart computers

foreach ($machine in $machines){
invoke-command -computername $machine -scriptblock {
    restart-computer -Force }
}

foreach($machine in $machines)
{
    Invoke-Command -ComputerName $machine -ScriptBlock {
    hostname
    if (get-service "Dynatrace OneAgent"){"$env:COMPUTERNAME : service Running"}
    if(test-path C:\ProgramData\dynatrace){"$env:COMPUTERNAME :folder is there"}
    }
}

#check last boot time

foreach($machine in $machines)
{
    $machine
   gcim -classname win32_operatingsystem -ComputerName $machine | select lastbootuptime
}

foreach($machine in $machines)
{
    $machine
    invoke-command -ComputerName $machine -ScriptBlock{
    Start-Process -FilePath "c:\users\ad_shalomp\downloads\Dynatrace-OneAgent-Windows-1.255.195.exe" -argu  --set-infra-only=false --set-app-log-content-access=true /quiet /forcerestart 
    }
}



#copy item
for ($i = 3; $i -lt 8; $i++)
{
    $session = new-pssession -ComputerName "psdnetapp0$i.m1.local"
    copy-item C:\Users\ad_shalomp\Downloads\Tenable\Dynatrace\* c:\users\ad_shalomp\downloads\ -ToSession $session

}


$machines = @("psdnetcc01","psdnetcc02","dnetmnp01","dnetmnp02")

Foreach ($k in $machines){
    "$k.m1.local"
}


