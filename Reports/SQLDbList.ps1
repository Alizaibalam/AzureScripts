$subs = Get-AzureRmSubscription
Write-Host " Found " $subs.count " Subscriptions"
$data = @()


foreach ( $sub in $subs )
{
  Select-AzureRmSubscription -SubscriptionName $sub.SubscriptionName | Out-Null

  Write-host "Getting list of resource groups in Subscription " $sub.SubscriptionName

  $rgs = Get-AzureRmResourceGroup

  Write-host "Found " $rgs.count "Resource Groups"

  Foreach ($rg in $rgs )
  {     
        $dbs = Get-AzureRmSqlServer -ResourceGroupName $rg.ResourceGroupName | Get-AzureRmSqlDatabase
        
        write-host "Found " $dbs.count " databases in Resource Group" $rg.ResourceGroupName

        foreach ( $db in $dbs)
        {
            $record = New-Object System.object
            $record | Add-Member -Type NoteProperty -Name Database -value $db.DatabaseName -Force
            $record | Add-Member -Type NoteProperty -Name ResourceGroup -value $db.ResourceGroupName -Force
            $record | Add-Member -Type NoteProperty -Name Subscription -value $sub.SubscriptionName -Force
            $record | Add-Member -Type NoteProperty -Name Servername -value $db.ServerName -Force
            $record | Add-Member -Type NoteProperty -Name Tags-BusinessOwner -value $db.Tags.BusinessOwner -Force
            $record | Add-Member -Type NoteProperty -Name Tags-CostCode -value $db.Tags.CostCode -Force
            $record | Add-Member -Type NoteProperty -Name Tags-ScheduleType -value $db.Tags.ScheduleType -Force
            $record | Add-Member -Type NoteProperty -Name Tags-Project -value $db.Tags.Project -Force
            $data = $data + $record
   }
   }

 }
 $data | export-csv c:\temp\dbReport.csv
