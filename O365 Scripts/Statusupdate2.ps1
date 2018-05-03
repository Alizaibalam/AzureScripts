#$SharedMailboxList = Import-Csv "RecipientMailboxlist.csv" #Gets the list of Shared Mailboxes from CSV
#Echo "Total Number of Mailboxes selected for processing " + $SharedMailboxList.count # Displays the number of mailboxes selected.
#Echo " Executing the commands on the shared mailboxes" #starting execution
#This section executes the commands on the complete list of mailboxes
$SMBX = get-mailbox -identity test-sharedMailbox

#****************** For All Mailboxes ******************  
ForEach ( $CM in $SMBX ) {
$UL=@()
$SG =@()
$TU = @()
$TSG = @()
  
    #******************  Getting the list of all the recipients who have Full Access to the Mailbox ******************  

    $FullAccessRecipients = Get-MailboxPermission -identity $CM.PrimarySMTPAddress | where { ($_.AccessRights -eq "FullAccess") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } 
   
   # ******************   Get Security Group from the Full Access Users ******************
   # this sections finds out the security group which is part of of the full access users.and determine the members of the security group   
    
    ForEach ($Entry in $FullAccessRecipients ) 
    { 
		     $UL += Get-Recipient -Identity $Entry.user
    } 
    ForEach ($Entry in $FullAccessRecipients ) 
    { 
		     $SG += Get-Recipient -Identity $Entry.user | ?{$_.RecipientType -ne "UserMailbox" }
	}
    if ( $sg -ne $null )
    {
        Write-Host "`n"
        Write-Host "Security Group: " $SG.identity "found with Full Acces to Shared Mailbox : "$CM.PrimarySMTPAddress
        write-host "`n"
        Write-host "Determining members of the security group : " $sg.identity
        write-host "`n"
        
                    # ******************   Get Security Group Members ******************  

        $SecurityGroupMembers = Get-MSOLGroupMember -GroupObjectId $sg.ExternalDirectoryObjectId
        Write-Host "Members found in security Group"  $SecurityGroupMembers.count
        write-host "`n"
        Write-Host "Granting Access to users ... " -foregroundcolor red  
        write-host "`n"
    
            # ******************  Granting sendonbehlfto Access to the members of the distributiongroup  ******************
     # this sections finds out the security group which is part of of the full access users.and determine the members of the security group   

        Foreach ($i in $SecurityGroupMembers)
        {
             Write-Host "Adding " $i.EmailAddress " to Test-sharedMaibox Send on behalf to" $CM.PrimarySMTPAddress
             set-mailbox -identity $CM.PrimarySMTPAddress -GrantSendonBehalfto @{Add= $i.EmailAddress}
         }
         Write-Host "Finished Working on " $CM.PrimarySMTPAddress -foregroundcolor red
         Write-host "`n"  
    }
    Else 
    {
      Write-Host " No security group has been granted Full access to the Mailbox : " $CM.PrimarySMTPAddress -ForegroundColor Green
      Write-host "`n"
      Write-host " Adding the users in the Full Access group  to the send on Behalf of list " $UL.count
      foreach ($i in $UL)
        {
        Write-Host "Adding " $i.PrimarySMTPAddress " to Test-sharedMaibox Send on behalf to" $CM.PrimarySMTPAddress
        set-mailbox -identity $CM.PrimarySMTPAddress -GrantSendonBehalfto @{Add=$i.PrimarySMTPAddress}
        }
         Write-Host "Finished Working on " $CM.PrimarySMTPAddress -foregroundcolor red
         Write-host "`n"
    }
 }
 