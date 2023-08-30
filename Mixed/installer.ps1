$machines=@("xavda108","xavda10")

foreach($machine in $machines){
    "installing on $machine"
    invoke-command -computername "$machine.m1.local" -scriptblock {
    &"c:\temp\DSM 20\Agent-Core-Windows-20.0.0-5995.x86_64.msi" /passive  }
}