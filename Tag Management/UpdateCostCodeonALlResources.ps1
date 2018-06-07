
$TagtoChange = @{Key="CostCode";Value="abcd"}

$resources = Get-AzureRmResource -ResourceGroupName digital-nprd-rg-01
Foreach($resource in $resources)
{
    $newtag = @{}
    $rtags= $resource.tags
    foreach ( $KVP in $rtags.GetEnumerator())
    { 
        If($KVP.Key -eq $TagtoChange.Key)
        { 
          write-host $TagtoRemove.Key "exists in the "$resource.Name " will be removed `n"
          $newtag.add("CostCode","RE-DT01-C03-FA")
          }
        Else 
        { 
        $newtag.add($KVP.Key,$KVP.Value) # Adding all the tags in the $newtag Variable except the $TagtoRemove.key values 
         }
     }
    #Updating the Virtual machine with the updated tag values $newtag.
 Set-AzureRmResource -ResourceId $resource.resourceid -Tag $newtag -Force
 }
