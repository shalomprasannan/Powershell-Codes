$sourceUser="in_sridhar"
$targetUser="in_rikeshnp"

$sourcegroups=Get-ADPrincipalGroupMembership $sourceuser

foreach ($group in $sourceGroups) {
    Add-ADGroupMember -Identity $group -Members $targetUser -ErrorAction SilentlyContinue
}
