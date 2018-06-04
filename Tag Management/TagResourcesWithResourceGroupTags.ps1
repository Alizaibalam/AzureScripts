$data = Import-Csv C:\temp\ResourceGroupCostCodeUpdate-trimmed.csv

Start-Transcript C:\temp\UpdateResourcesWithResourceGroupTags.txt

foreach ($Record in $data)
{
    $group = Get-AzureRmResourceGroup $Record.ResourceGroup
    
    if ($group.Tags -ne $null) {
        $resources = Get-AzureRmResource -ResourceGroupName $group.ResourceGroupName
        foreach ($r in $resources)
        {
            $resourcetags = (Get-AzureRmResource -ResourceId $r.ResourceId).Tags
            if ($resourcetags)
            {
                foreach ($key in $group.Tags.Keys)
                {
                    if (-not($resourcetags.ContainsKey($key)))
                    {
                        $resourcetags.Add($key, $group.Tags[$key])
                    }
                }
                Write-Host " Updating " $r.Name 
                $result = Set-AzureRmResource -Tag $resourcetags -ResourceId $r.ResourceId -Force
                write-host "Updated Tags value for the resource " $r.Name ($result.tags| out-string ) -ForegroundColor Green
            }
            else
            {
                $result = Set-AzureRmResource -Tag $group.Tags -ResourceId $r.ResourceId -Force
                write-host "Updated Tags value for the resource " $r.Name ($result.tags| out-string ) -ForegroundColor Green
            }
        }
    }
 }
 Stop-Transcript
