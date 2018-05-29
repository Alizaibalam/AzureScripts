 $currentTime = Get-Date
 $rg = Get-AzureRmResourceGroup -Name snrg02
 $endTime = $currentTime.AddDays(-7 * $cnt)
 $startTime = $endTime.AddDays(-7)
 $callers = Get-AzureRmLog -ResourceGroup $rg.ResourceGroupName -StartTime $startTime -EndTime $endTime -WarningAction SilentlyContinue |
        Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write" -or $_.Authorization.Action -eq "Microsoft.Resources/subscriptions/resourcegroups/write" } | 
        Select -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select -ExpandProperty Name

    if ($callers)
   {
        $owner = $callers | Select-Object -First 1
        $alias = $owner -replace "@microsoft.com",""

        $tags = (Get-AzureRmResourceGroup -Name $rg.ResourceGroupName).Tags
        $tags += @{ "CREATED-BY"=$alias }

        #$rg + ", " + $alias
        if (-not $dryRun) 
        {
            Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags
        }
    } 
    else 
    {
        #$rg + ", Unknown"
    }
