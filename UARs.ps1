$machines=get-content C:\users\ad_shalomp\Documents\Scripts\machines.txt
$data=@()
foreach ($machine in $machines){
    $Admins_raw=invoke-command -computername "$machine.m1.local" -ScriptBlock {net localgroup administrators}
    $users_raw=invoke-command -computername "$machine.m1.local" -ScriptBlock {net localgroup users}
    $RDP_raw=invoke-command -computername "$machine.m1.local" -ScriptBlock {net localgroup 'remote desktop users'}
    $Admins=$Admins_raw|select -Skip 7 | select -SkipLast 2
    $users=$users_raw|select -Skip 7 | select -SkipLast 2
    $RDP=$RDP_raw|select -Skip 7 | select -SkipLast 2
    $data+=[pscustomobject]@{
        Admins=$admins
        Users=$users
        RDP=$RDP
        Name=$machine
    }
}

$excel=@()

$excel_Admins = $data.admins | sort -Unique

foreach($admin in $excel_admins){
    $excel+=[pscustomobject]@{
        Account=$admin
    }
}

$compared=@()
#looping through each machine
foreach($entry in $data){
    #looping through each account
    foreach($admin in $excel_admins){
        
        if($admin -in $entry.admins ){
            $flag="Yes"
        }
        else{

            $flag="No"
        }
        
        $excel|where Account -eq $admin|Add-Member -NotePropertyName $($entry.name) -NotePropertyValue $flag 

        $flag=""
    }
}
