# ************ Getting Start and End time for Log search *****************

$currentTime = Get-Date
$rg = Get-AzureRmResourceGroup -Name snrg02
$endTime = $currentTime.AddDays(-7 * $cnt)
$startTime = $endTime.AddDays(-7)


# ************ Getting list of all subscriptions *****************

$subs = Get-AzureRmSubscription
$Report = @()

foreach ( $sub in $subs )
{
    Select-AzureRmSubscription -SubscriptionName $subs.Name | out-Null

    # Getting list of the resource groups with no CreatedBy Tag 

    $untaggedResourceGroups = Get-AzureRmResourceGroup | Where-Object { $_.Tags.CreatedBy -eq $null }

    foreach ( $rg in $untaggedResourceGroups)
    {
        $callers = Get-AzureRmLog -ResourceGroup $rg.ResourceGroupName -StartTime $startTime -EndTime $endTime -WarningAction SilentlyContinue |
        Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write" -or $_.Authorization.Action -eq "Microsoft.Resources/subscriptions/resourcegroups/write" } | 
        Select -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select -ExpandProperty Name

        if ($callers)
        {
        $alias = $callers | Select-Object -First 1
        $tags = (Get-AzureRmResourceGroup -Name $rg.ResourceGroupName).Tags
        $tags += @{ "CreatedBy"=$alias }
        if (-not $dryRun) 
        {
            Write-Host " Adding $tags to $rg.Name) "
            # Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags
        }
    } 
    else 
    {
         $tags += @{ "CreatedBy"="un-known" }
         if (-not $dryRun) 
        {
             Write-host " Adding $tags to $rg.Name"
            #Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $tags
        }
    }
    }
    
}
