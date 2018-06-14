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

$primaryKey = ConvertTo-SecureString -String 'lfEUoOl4B933hiCUY5aL7Cx0I4of1AF84r1Dg0GYOGZScaO4Mwwwid5kvvbnlUFyfVIhDFwK5eDoNNWJX02SfA==' -AsPlainText -Force
$cosmosDbContext = New-CosmosDbContext -Account 'snsqlcosmosdb' -Database 'ResourceGroupTags' -Key $primaryKey
New-CosmosDbCollection -Context $cosmosDbContext -Id 'Rgtags2' -OfferThroughput 1000 | Out-Null
$Subscriptions = (Get-AzurermSubscription).Name 
$date = Get-date -Format ddMMyyyy

# Loop through all ARM subscriptions
ForEach ($Sub in $Subscriptions)
{
    Write-Output 'Looping through subscription' $Sub
    Select-AzureRmSubscription -SubscriptionName $sub | Out-Null
    $ResourceGroups = Get-AzureRmResourceGroup
    foreach ($ResourceGroup in $ResourceGroups) 
    {
                 $document = @"
{
    `"id`": `"$(($ResourceGroup.ResourceGroupName))`",
    `"costcode`": `"$(($ResourceGroup.Tags.CostCode))`",
    `"createdby`": `"$(($ResourceGroup.Tags.CreatedBy))`",
    `"subscription`": `"$sub`",
    `"date`": `"$date`",
    `"more`": `"Some other string`"
}
"@
                #$document = $Record | Convertto-json   This step was not required.
                Try {
                        # write-output $document
                        New-CosmosDbDocument -Context $cosmosDbContext -CollectionId 'Rgtags2' -DocumentBody $document
                        Write-Output "Resource Group:" $resourceGroup.ResourceGroupName  " data was added to the database"
                    }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $ErrTMD = (Get-Date) 
                    "Error with Database Update occurred at : {0:HH:mm:ss MM-dd-yyyy}..." -f $ErrTMD 
                    Write-Output "Adding $Record.Title to $Cosmosdbcontext.Database failed with error message $ErrorMessage"
                    Start-Sleep -Milliseconds 1000
                    }
        }
   
}

      