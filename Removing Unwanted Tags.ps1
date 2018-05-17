#Getting the list of VMs based on the resource group. THe Scope can be changed to include more resources.

$VMS = Get-AzureRmVM -ResourceGroupName snrg01

#Details of the tag to remove are stored in the $TagtoRemove variable.

$TagtoRemove = @{Key="TestVmName";Value="abcd"}

foreach ($VM in $VMs)
{
    $VMtags = $VM.tags # Getting the list of all the tags for the VM.
    $newtag = @{} # Creating a new Hashtable variable to store the Tag Values.
    foreach ( $KVP in $VMtags.GetEnumerator() )
    { 
         Write-Host "`n`n`n"
         If($KVP.Key -eq $TagtoRemove.Key)
         { 
           write-host $TagtoRemove.Key "exists in the "$VM.Name " will be removed `n"}
         Else 
         { 
     
           $newtag.add($KVP.Key,$KVP.Value) # Adding all the tags in the $newtag Variable except the $TagtoRemove.key values 
         }

     }
    #Updating the Virtual machine with the updated tag values $newtag.
    Set-AzureRmResource -ResourceGroupName $VM.ResourceGroupName -ResourceName $VM.Name -Tag $newtag -Force -ResourceType Microsoft.Compute/VirtualMachines
}
