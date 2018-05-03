$SharedMailboxList = Import-Csv "RecipientMailboxlist.csv" #Gets the list of Shared Mailboxes from CSV
Echo "Total Number of Mailboxes selected for processing " + $SharedMailboxList.count # Displays the number of mailboxes selected.
Echo " Executing the commands on the shared mailboxes" #starting execution
#This section executes the commands on the complete list of mailboxes

ForEach ( $CurrentMailbox in $SharedMailboxList ) {

    #Getting the list of all the recipients who have Full Access to the Mailbox
    $FullAccessRecipients = Get-MailboxPermission -identity $CurrentMailbox.PrimarySMTPAddress | where { ($_.AccessRights -eq "FullAccess") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } 
    #Get Security Group from the Full Access Users
    ForEach ($Entry in $FullAccessRecipients ) { 
		     $SG = Get-Recipient -Identity $i.Trustee | ?{$_.RecipientType -ne "UserMailbox" }
	     }
    #Getting the users from FullAccess Recipients
    ForEach ($Entry in $FullAccessRecipients ) { 
		     $Users = Get-Recipient -Identity $i.Trustee | ?{$_.RecipientType -eq "UserMailbox" }
	     } 
         
         #Granting Users with SendAs permissions to the Mailbox.
         ForEach ($Entry in $FullAccessUsers ) { 
		        Add-RecipientPermission $CurrentMailbox.PrimarySMTPAddress -AccessRights SendAS -Trustee $entry.user -Confirm:$False
	     }
    Echo $CurrentMailbox.PrimarySMTPAddress + "Updated"
}


