    $objects=@(
@{machine = "Mercury101"; packs = @("KB5022838")},
@{machine = "Mercury102"; packs = @("KB4023307","KB4089501","KB4091346","KB4087371","KB4089283","KB4506161","KB4506162","KB4506163","KB4506164","KB4540102")},
@{machine = "Mercury103"; packs = @("KB5022838")},
@{machine = "Pluto102"; packs = @("KB5022838")}
)

foreach($object in $objects){

#$session = new-pssession -ComputerName "$($object.machine).m1.local"
    foreach($kb in $object.packs){

        #get-childitem -path C:\Users\ad_shalomp\Downloads\Tenable\kb\ -filter *$kb* |copy-item c:\users\ad_shalomp\downloads\ -ToSession $session
        #copy-item -path -destination c:\users\ad_shalomp\downloads\ -ToSession $session
        #Invoke-Command -ComputerName $($object.machine).m1.local -ScriptBlock{
        #Start-Process -FilePath "wusa.exe" -ArgumentList "c:\users\ad_shalomp\dowloads\kb\*$KB* /quiet /norestart" -Wait }
        $path = (get-childitem C:\users\ad_shalomp\downloads\Tenable\kb\*$kb*|select name).name
        Robocopy C:\users\ad_shalomp\downloads\Tenable\kb\$path  \\$($object.machine)\C$\ad_shalomp\downloads\kb /MT:8 /Z

    }

}


