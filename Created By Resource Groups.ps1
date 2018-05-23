$currentTime = Get-Date
$endTime01 = $currentTime.AddDays(-7 * $cnt)
$startTime01 = $endTime.AddDays(-83)


Start-Transcript -Path c:\temp\callers.txt
$subs  = Get-AzureRmSubscription
$report = @()
foreach ($sub in $subs )
{
    Select-AzureRmSubscription -SubscriptionName $sub.Name| Out-Null
    $rgs = Get-AzureRmResourceGroup
    
    foreach ( $rg in $rgs)
    {
        try 
        {
        $record = @()
        #$caller = NULL
        $recordCreation = Get-AzureRmLog -ResourceGroup $rg.ResourceGroupName -StartTime $startTime01 -EndTime $endTime01 -WarningAction SilentlyContinue |Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write" -or $_.Authorization.Action -eq "Microsoft.Resources/subscriptions/resourcegroups/write" } 
        $recordModification = Get-AzureRmLog -ResourceGroup $rg.ResourceGroupName -StartTime $startTime01 -EndTime $endTime01 -WarningAction SilentlyContinue
        $Creator = $record | select -ExpandProperty Caller | Group-Object | Sort-Object | Select -ExpandProperty Name
        $timeCreation= $record | select EventTimestamp | Sort-Object | Select-Object -First 1
        $timemodification = $recordModification | select EventTimestamp | Select-Object -First 1
        $lastModifier  = $recordModification | select -ExpandProperty Caller | Select-Object -First 1
        }
        Catch
        {}
        $row = New-Object psobject
        $row | Add-Member -Type NoteProperty -Name 'Resource Group Name' -Value $rg.ResourceGroupName
        $row | Add-Member -Type NoteProperty -Name 'Created By ' -Value $Creator
        $row | Add-Member -Type NoteProperty -Name 'Creation Date ' -Value $timeCreation
        $row | Add-Member -Type NoteProperty -Name 'Last Modification ' -Value $timemodification.EventTimeStamp
        $row | Add-Member -Type NoteProperty -Name 'Last Modified By ' -Value $lastModifier
        $row | Add-Member -Type NoteProperty -Name 'Subscription' -Value $Sub.Name  
        $row | Add-Member -Type NoteProperty -Name 'Location' -Value $rg.Location
        write-host $rg.ResourceGroupName" , "$Creator " , "$timeCreation " , " $timemodification " , " $lastModifier " , "$Sub.Name" , "$rg.Location "`n"
        $report = $report + $row
    }
    

}

$report | export-csv C:\temp\Callers.csv

Stop-Transcript
