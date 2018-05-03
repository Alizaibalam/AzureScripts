$DGlist=Import-csv C:\Scripts\Work\DGList.csv
$user1 = Get-user -identity lucindataaffe@qantas.com.au
$user2 = Get-user -identity piabatson@qantas.com.au
$DGErrorlucinda.Clear
$DGErrorpia.clear
$space=" "
Foreach ( $i in $DGlist)
{
$DGroup=Get-distributionGroup -identity $I.Identity
remove-distributionGroupMember -identity $i.Identity -Member $User1.Name -Confirm:$false
if($?)
{
   Write-Host " User Lucinda Taaffe has been removed from the " $I.identity " Group"
}
else
{
    $DGErrorLucinda = $DGErrorlucinda + $DGroup.Name
}
remove-distributionGroupMember -identity $i.Identity -Member $User2.Name -Confirm:$false
if($?)
{
   Write-Host " User Pia baston has been removed from the " $I.identity " Group"
}
else
{
   $DGErrorpia = $DGErrorpia + $space + $DGroup.Name
}
}
Write-Host ""
Write-Host ""
Write-Host ""

Write-Host " ******************* Error Status Lucinda*******************"
Write-host ""
write-host "Lucinda not removed from the following DGs "
Write-host ""
Foreach ($e in $DGErrorlucinda )
{ Write-host " Distribution Group Name : " $e
Write-host ""
}

Write-Host " ******************* Error Status Pia Batson*******************"
Write-Host ""
write-host "Pia baston not removed from the following DGs "
Write-host ""
Foreach ($e in $DGErrorpia )
{ Write-host " Distribution Group Name : " $e
Write-host ""
}