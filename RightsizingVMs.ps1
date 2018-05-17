Write-Output "Authenticating"
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

Select-AzureRmSubscription -SubscriptionName ISG-Development

$VMs = Get-AzureRmVM -ResourceGroupName snrg01
    
foreach ( $vm in $Vms)
{
    $Vmstatus = (Get-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Status).Statuses[1].DisplayStatus
    $VmRightsize = $($VM.Tags.RightSize)
    If ( $VmRightsize -eq $VM.HardwareProfile.VMSize)
    {
       Write-Output " Machine $($Vm.Name) already right sized "
    }
    ElseIf ( $Vmstatus -ne "VM deallocated")
    {
      write-Output " Virtual Machine $($Vm.name) is not in the correct status to perform operation"
    }
    Else
    {
       $OldSize = $Vm.hardwareProfile.VmSize
       $VM.HardwareProfile.VmSize = $VmRightsize
       $UpdateStatus = Update-AzureRmVM -VM $VM -ResourceGroupName snrg01
       Write-Output "Machine $($Vm.name) Rightsize from $OldSize to $VmRightsize completed with status:$($UpdateStatus.StatusCode) and SucessStatusCode:$($UpdateStatus.IsSuccessStatusCode)"
     }     
}
