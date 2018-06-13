$subs = Get-AzureRmSubscription -SubscriptionName Retail-development

foreach ( $sub in $subs)
{
   $rgs = Get-AzureRmResourceGroup
   
   foreach($rg in $rgs)
   {
    
        IF(!$rg.Tags.CostCode)
        {
            $vms = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName            
            If($vms)
            { 
               foreach ($vm in $vms)
               { 
                    If($vm.Tags.CostCode)
                    { 
                     
                    $rgtags = $rg.Tags
                    $rgtags.add("CostCode",$vm.Tags.CostCode)
                    Write-host "Updating Resource Group " $rg.ResourceGroupName "with Cost Code for VM " $vm.Name
                    Set-AzureRmResourceGroup -Name $rg.ResourceGroupName -Tag $rgtags
                    break
                    }
                }
            }   
        }
   }

}
