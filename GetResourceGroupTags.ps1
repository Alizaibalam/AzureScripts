$subs  = Get-AzureRmSubscription
$report = @()
foreach ($sub in $subs )
{
    Select-AzureRmSubscription -SubscriptionName $sub.Name 
    $rgs = Get-AzureRmResourceGroup
    
    foreach ( $rg in $rgs)
    {
    $row = New-Object psobject
    $row | Add-Member -Type NoteProperty -Name 'Resource Group Name' -Value $rg.ResourceGroupName
    $row | Add-Member -Type NoteProperty -Name 'Location' -Value $rg.Location
    $row | Add-Member -Type NoteProperty -Name 'Tags-Application' -Value $rg.Tags.Application
    $row | Add-Member -Type NoteProperty -Name 'Tags-BusinessOwner' -Value $rg.Tags.BusinessOwner
    $row | Add-Member -Type NoteProperty -Name 'Tags-SchedExemption' -Value $rg.Tags.SchedExemption
    $row | Add-Member -Type NoteProperty -Name 'Tags-TechnicalOwner' -Value $rg.Tags.TechnicalOwner
    $row | Add-Member -Type NoteProperty -Name 'Tags-environment' -Value $rg.Tags.environment
    $row | Add-Member -Type NoteProperty -Name 'Tags-ScheduleType' -Value $rg.Tags.ScheduleType
    $row | Add-Member -Type NoteProperty -Name 'Tags-Schedule' -Value $rg.Tags.Schedule
    $row | Add-Member -Type NoteProperty -Name 'Tags-environmentType' -Value $rg.Tags.environmentType
    $row | Add-Member -Type NoteProperty -Name 'Tags-subenvironment' -Value $rg.Tags.subenvironment
    $row | Add-Member -Type NoteProperty -Name 'Tags-expirationDate' -Value $rg.Tags.expirationDate
    $row | Add-Member -Type NoteProperty -Name 'Tags-Dept' -Value $rg.Tags.Dept
    $row | Add-Member -Type NoteProperty -Name 'Tags-Project' -Value $rg.Tags.Project
    $row | Add-Member -Type NoteProperty -Name 'Tags-CostCode' -Value $rg.Tags.CostCode
    $row | Add-Member -Type NoteProperty -Name 'Tags-Owner' -Value $rg.Tags.Owner
    $row | Add-Member -Type NoteProperty -Name 'Tags-Team' -Value $rg.Tags.Team
    $row | Add-Member -Type NoteProperty -Name 'Subscription' -Value $Sub.Name  
    $report = $report + $row

    }
}
$report | export-csv C:\temp\resourceGroups.csv
