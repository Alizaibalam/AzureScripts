Copy-Item -Path \servername\va_ts_naqvisye\Documents\Scripts\*.* -Destination C:\temp\
$name= (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$ReportingPath = "\\servername\Users\va_ts_naqvisye\Documents\ScriptsVISY\Scripts\"+$name
New-item -ItemType directory -Path $ReportingPath
$outputlocation = $ReportingPath +"\checkdoaminresult.csv"
C:\temp\Check_domain.ps1 > $Outputlocation

$outputlocation = $ReportingPath +"\disk_config.csv"
C:\temp\Disk_config.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\MShotfix.csv"
C:\temp\Get-MSHotfix.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\Get-schduledtask.csv"
C:\temp\Get-ScheduledTask.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\get-services.csv"
C:\temp\Get-Services.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\get-updatesetttings.csv"
C:\temp\Get-Update_setting.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\instaledsoftware1.csv"
C:\temp\Installed_software1.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\InstallSoftware2.csv"
C:\temp\Installed_software2.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\LocalUsersGroups.csv"
C:\temp\Local_users_groups.ps1 > $Outputlocation


$outputlocation = $ReportingPath +"\OsConfig.csv"
C:\temp\OS_config.ps1 > $Outputlocation

$outputlocation = $ReportingPath +"\Hostfie.csv"
C:\temp\Hostfile.ps1 > $Outputlocation

$outputlocation = $ReportingPath + "\Netsh.txt"
C:\temp\netsh.ps1 > $outputlocation

Remove-Item -Path  C:\temp\OS_config.ps1
Remove-Item -Path  C:\temp\Local_users_groups.ps1
Remove-Item -Path  C:\temp\Installed_software2.ps1
Remove-Item -Path  C:\temp\Installed_software1.ps1
Remove-Item -Path  C:\temp\Get-Update_setting.ps1
Remove-Item -Path  C:\temp\Get-Services.ps1
Remove-Item -Path  C:\temp\Get-ScheduledTask.ps1
Remove-Item -Path  C:\temp\Get-MSHotfix.ps1
Remove-Item -Path  C:\temp\Disk_config.ps1
Remove-Item -Path  C:\temp\Check_domain.ps1
Remove-Item -Path  C:\temp\Hostfile.ps1
Remove-Item -Path C:\temp\netsh.ps1
Remove-Item -Path C:\temp\Installed_software.ps1
Remove-Item -Path C:\temp\MasterScript.ps1
Remove-Item -Path C:\temp\Networking_config.txt
