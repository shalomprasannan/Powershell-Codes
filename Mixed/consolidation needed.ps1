# Connect to vSphere server with PowerCLI
Connect-VIServer -Server mocvcms11.m1.local
Connect-VIServer -Server rocvcms11.m1.local

# Get a list of VMs that have unconsolidated disks
get-vm|select * |where {$_.ExtensionData.ConfigIssue.eventtypeid -like '*consolidationneed*'}| select Name, @{l="spaceTB";e={[Math]::Round($($_.usedspaceGB)/1024,2)}}

# Disconnect from vSphere server
#Disconnect-VIServer -Confirm:$false
