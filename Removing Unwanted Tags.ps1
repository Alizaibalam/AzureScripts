$VMS = Get-AzureRmVM -ResourceGroupName snrg01
$TagtoRemove = @{Key="TestVmName";Value="abcd"}
foreach ($VM in $VMs)
{
    $VMtags = $VM.tags
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
    Set-AzureRmResource -ResourceGroupName $VM.ResourceGroupName -ResourceName $VM.Name -Tag $newtag -Force -ResourceType Microsoft.Compute/VirtualMachines
}
