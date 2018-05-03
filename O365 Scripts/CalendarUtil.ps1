#Imports Exchange Online Session and O365 Connectivity
#Set-ExecutionPolicy unrestricted -Confirm:$false -Scope CurrentUser

Remove-Item 'C:\PS\CalendarReport\*'

Get-PSSession | Remove-PSSession
#$Username ="john.toledo@qantas.onmicrosoft.com"
#$Pass = cat Y:\john\Password\pass.txt | ConvertTo-SecureString
#$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username,$pass
$cred = Get-Credential
Import-Module MSonline

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication Basic -AllowRedirection -Credential $Cred
Import-PSSession $Session
Connect-MsolService -Credential $Cred

#Import EWS Module
 
Import-Module "C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.1\Microsoft.Exchange.WebServices.dll" 
$EndDate =   (Get-Date).AddDays(-8)
$StartDate = ($EndDate).AddMonths(-1)

$folderPath = "C:\PS\CalendarReport\"
$path = $folderPath + "MeetingRoomUtilization" + (Get-Date).ToString("yyyy-MM-dd-hh-mm-ss") + ".csv" 
   
$MailboxName = 'john.toledo@qantas.com.au'
  
$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013_SP1   
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)   
$psCred = $Cred
$creds = New-Object System.Net.NetworkCredential($psCred.UserName.ToString(),$psCred.GetNetworkCredential().password.ToString())   
$service.Credentials = $creds       
$service.AutodiscoverUrl($MailboxName,{$true})   
"Using CAS Server : " + $Service.url    
 
$meetingRooms = Get-mailbox "BNEHG*"
#$meetingRooms = Get-mailbox "sydqcc.2.M*"
#$meetingRooms = Get-mailbox SYDQCC.2.MTG008@qantas.com.au 
 
Foreach($meetingRoom in $meetingRooms) 
{ 
 
$MailboxName = $meetingRoom.PrimarySmtpAddress    
$RptCollection = @() 
 
$service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $MailboxName)  
 
# Bind to the Calendar Folder 
$folderid= new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar,$MailboxName)     
$Calendar = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,$folderid) 
$Recurring = new-object Microsoft.Exchange.WebServices.Data.ExtendedPropertyDefinition([Microsoft.Exchange.WebServices.Data.DefaultExtendedPropertySet]::Appointment, 0x8223,[Microsoft.Exchange.WebServices.Data.MapiPropertyType]::Boolean);  
$psPropset= new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)   
$psPropset.Add($Recurring) 
$psPropset.RequestedBodyType = [Microsoft.Exchange.WebServices.Data.BodyType]::Text; 
 
  #Define the calendar view   
$CalendarView = New-Object Microsoft.Exchange.WebServices.Data.CalendarView($StartDate,$EndDate,1000)     
$fiItems = $service.FindAppointments($Calendar.Id,$CalendarView) 
if($fiItems.Items.Count -gt 0) 
{ 
 $type = ("System.Collections.Generic.List"+'`'+"1") -as "Type" 
 $type = $type.MakeGenericType("Microsoft.Exchange.WebServices.Data.Item" -as "Type") 
 $ItemColl = [Activator]::CreateInstance($type) 
 foreach($Item in $fiItems.Items) 
 { 
  $ItemColl.Add($Item) 
 }  
 [Void]$service.LoadPropertiesForItems($ItemColl,$psPropset)   
} 
foreach($Item in $fiItems.Items) 
{       
 $rptObj = "" | Select StartTime,EndTime,Duration,Subject,Organizer,Room,Attendees,NumberofParticipants
 $rptObj.StartTime = $Item.Start   
 $rptObj.EndTime = $Item.End   
 $rptObj.Duration = $Item.Duration 
 $rptObj.Subject  = $Item.Subject    
 $rptObj.Organizer = $Item.Organizer.Address 
 $rptObj.Room = $meetingRoom.DisplayName
 $rptObj.Attendees = $Item.DisplayTo
 $rptObj.NumberofParticipants = ($item.RequiredAttendees.Count + $item.OptionalAttendees.Count)
 $RptCollection += $rptObj  
}    
 
$exportPath = $folderPath + $MailboxName + "-CalendarCSV" + (Get-Date).ToString("yyyy-MM-dd-hh-mm-ss") + ".csv" 
 
$RptCollection | Export-Csv -NoTypeInformation -Path $exportPath 
}
 
#dir $folderPath -Filter *.csv | %{Import-Csv -Path $folderPath$_} | Export-Csv -Path $path -NoTypeInformation 
#credentials

#$smtppass = cat Y:\John\Password\smtppass.txt | ConvertTo-SecureString
#$emailcred = New-Object System.Net.NetworkCredential($Username,$smtppass)

#Send Email#

#$fromaddress = $Username
#$toaddress = "yvetteoudgenoeg@qantas.com.au, gavinspeak@qantas.com.au"
#$toaddress = "johntoledo@qantas.com.au"
#$bccaddress =  "johntoledo@qantas.com.au"
#$CCaddress = 
#$Subject = “Meeting Room Utilization from $StartDate to $EndDate” 
#$body = "Please see attached file for Meeting Room Utilization for the past 30 days." 
#$attachment = $path
#$smtpserver = "outlook.office365.com"
 
#################################### 
 
#$message = new-object System.Net.Mail.MailMessage 
#$message.From = $fromaddress 
#$message.To.Add($toaddress) 
#$message.CC.Add($CCaddress) 
#$message.Bcc.Add($bccaddress) 
#$message.IsBodyHtml = $True 
#$message.Subject = $Subject 
#$attach = new-object Net.Mail.Attachment($attachment)
#$message.Attachments.Add($attach) 
#$message.body = $body
#$smtp = new-object Net.Mail.SmtpClient($smtpserver, 587)
#$smtp.EnableSsl = $true
#$smtp.Credentials = $emailcred
#$smtp.Send($message) 

####################################

#Remove-Item Y:\John\CalendarReport\*

Get-PSSession | Remove-PSSession