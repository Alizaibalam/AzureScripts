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

$SPOCreds = Get-AutomationPSCredential -Name 'sharepoint'
$SPOURL = "https://aglenergy.sharepoint.com/sites/CloudPlatformsEngineering/"
$SPOListName = "ResourceGroupTags"


$Subscriptions = (Get-AzurermSubscription).Name 

# Loop through all ARM subscriptions
ForEach ($Sub in $Subscriptions)
{
    Write-Output 'Looping through subscription' $Sub
    Select-AzureRmSubscription -SubscriptionName "$Sub" | Out-Null
    $ResourceGroups = Get-AzureRmResourceGroup
    foreach ($ResourceGroup in $ResourceGroups) 
    {
               $Record = @{
                Title  = $ResourceGroup.ResourceGroupName
                Subscription   = $Sub
                BusinessOwner  = ($ResourceGroup).tags.BusinessOwner
                CostCode       = ($ResourceGroup).tags.CostCode
                TechnicalOwner  = ($ResourceGroup).tags.TechnicalOwner
                Date = (Get-date -Format ddMMyyyy)}
                
                Try {
                        Write-Output "CPE machine to be added to SharePoint. Title : $Name Type : $Type Subscription : $Sub Size : $Size"
                        Add-SPListItem -SiteUrl $SPOURL -Credential $SPOCreds -IsSharePointOnlineSite $true -ListName $SPOListName -ListFieldsValues $Record
                    }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $ErrTMD = (Get-Date) 
                    "Error with Sharepoint occurred at : {0:HH:mm:ss MM-dd-yyyy}..." -f $ErrTMD 
                    Write-Output "Adding $Name to $SPOListName Sharepoint list failed with error message $ErrorMessage"
                    Start-Sleep -Milliseconds 1000
                    }
        }
   
}

      
