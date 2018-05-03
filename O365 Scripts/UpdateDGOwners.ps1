$DGlist=Import-csv C:\Scripts\Work\DGList.csv
$user1 = Get-user -identity lucindataaffe@qantas.com.au
$user2 = Get-user -identity piabatson@qantas.com.au
$DGError.Clear
Foreach ( $i in $DGlist)
{ 

$DGroup=Get-distributionGroup -identity $I.Identity
$ManagedBy=$DGroup.Managedby
$UpdatedManagedBy = $ManagedBy + $User1.Name + $User2.Name
set-distributionGroup -identity $I.identity -Managedby $UpdatedManagedBy
if($?)
{
   Write-Host " Distribution Group " $I.identity " Has been updated"
}
else
{
   $DGError = $DGError + $DGroup.Name
}
}
write-host "Mentioned below are the Distribution groups that have not been updated "
$DGError