$startTMD = (Get-Date)
"Starting Script: {0:HH:mm MM-dd-yyyy}..." -f $startTMD
# Authenticate to Azure ARM and Sharepoint
$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# ************ Getting Start and End time for Log search *****************

$currentTime = Get-Date
$endTime = $currentTime
$startTime = $endTime.AddDays(-89)

# ************ Getting list of all subscriptions *****************

$subs = Get-AzureRmSubscription -SubscriptionName Retail-development

foreach ( $sub in $subs )
{
    Select-AzureRmSubscription -SubscriptionName $subs.Name | out-Null

    # Getting list of the resource groups with no CreatedBy Tag 

    $untaggedResourceGroups = Get-AzureRmResourceGroup | Where-Object { $_.Tags.CreatedBy -eq $null }
    write-output "Found $(($untaggedresourcegroups).count) resource groups with no Created BY Account."

    foreach ( $rg in $untaggedResourceGroups)
    {
        write-output " --------------------------------------------------"
        write-output "Working on Resource Group $($rg.ResourceGroupName)"
        $callers = Get-AzureRmLog -ResourceGroup $($rg.ResourceGroupName) -StartTime $startTime -EndTime $endTime -WarningAction SilentlyContinue |
        Where {$_.Authorization.Action -eq 'Microsoft.Resources/deployments/write' -or $_.Authorization.Action -eq 'Microsoft.Resources/subscriptions/resourcegroups/write' } | 
        Select -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select -ExpandProperty Name

        if ($callers)
        {
        write-output $callers | Out-string
        $alias = $callers | Select-Object -Index ($callers.count-1)
        if ($alias -match "A142890@agl.com.au")
        {
            $alias ="Unknown"
            }
        $rgtags = ($($rg.Tags))
        if(!$rgtags)
        {
                 $rgtags = @{}
        }
        $rgtags.add("CreatedBy","$alias")
        write-output " Adding the Following Tags to the resource group"
        Write-Output ($rgtags | Out-String)
        Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $rgtags
            } 
    else 
    {
        write-output " No user found. Created By user is Unknown"
        $rgtags = ($($rg.Tags))
        $alias = "Unknown"
        if(!$rgtags)
        {
            $rgtags = @{}
        }
        $rgtags.add("CreatedBy","$alias")
        write-output " Adding the Following Tags to the resource group"
        Write-Output ($rgtags | Out-String)
        Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $rgtags
             
     }
    }
}
