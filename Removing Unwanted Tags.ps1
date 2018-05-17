$VMtags = (Get-AzureRmVM -ResourceGroupName snrg01 -Name snvm02).tags
$TagtoRemove = @{Key="TestVmName";Value="abcd"}
$newtag = @{}

foreach ( $KVP in $VMtags.GetEnumerator() )
{ 
     Write-Host "`n`n`n"
     If($KVP.Key -eq $TagtoRemove.Key){ write-host $Key "exists in "  $TagtoRemove.Key "`n"}
     Else 
     { 
     
     write-host " Adding " $KVP
     $newtag.add($KVP.Key,$KVP.Value)
     }


}
