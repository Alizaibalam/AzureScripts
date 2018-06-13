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
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
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

$subs = Get-AzureRmSubscription -SubscriptionName Retail-Development
foreach ( $sub in $subs)
{
   write-output " Checking Subscription $($sub.Name)"
   select-azurermsubscription -SubscriptionName $($sub.Name)
   $rgs = Get-AzureRmResourceGroup
   foreach($rg in $rgs)
   {
        write-output "###################################################### "
        write-output "$($rg.ResourceGroupName) : Checking Resource Group Group tags  $($($rg.tags).testname)"
        IF(!$($($rg.tags).testname))
        {
            write-output "$($rg.ResourceGroupName): No Cost Code Tag Found"
            write-output "$($rg.ResourceGroupName): Getting list of VMs in Resource Group"
            $vms = Get-AzureRmVM -ResourceGroupName $($rg.ResourceGroupName)
            If($vms)
            { 
               write-output "$($rg.ResourceGroupName): $($vm.Count) VMs found in Resource Group. Checking for Cost Code" 
               foreach ($vm in $vms)
               { 
                    If($($($vm.Tags).CostCode))
                    { 
                    $rgtags = $($rg.Tags)
                    $rgtags.add("CostCode","$($($vm.Tags).CostCode)")
                    Write-host "$($rg.ResourceGroupName): Updating Resource Group $($rg.ResourceGroupName) with Cost Code for VM $($vm.Name)"
                    write-host "$($rgtags.CostCode)"
                    #Set-AzureRmResourceGroup -Name $($rg.ResourceGroupName) -Tag $rgtags
                    break
                    }
                    write-output " $($rg.ResourceGroupName): VM $($Vm.name) does not have cost code. Checking further..."
                }
            }
            Else
            {
                write-OUtput "$($rg.ResourceGroupName): No VMS found in the Resource Group"
            }   
        }
   }
