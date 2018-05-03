$SharedMailboxList = Import-Csv "RecipientMailboxlist.csv" #Gets the list of Shared Mailboxes from CSV
Echo "Total Number of Mailboxes selected for processing " + $SharedMailboxList.count # Displays the number of mailboxes selected.
Echo " Executing the commands on the shared mailboxes" #starting execution
#This section executes the commands on the complete list of mailboxes

ForEach ( $CurrentMailbox in $SharedMailboxList ) {

    #Getting the list of all the recipients who have Full Access to the Mailbox
    $SendAsAccessUsers = Get-Mailbox -identity domccops | Get-RecipientPermission | ? {$_.Trustee -ne "NT AUTHORITY\SELF"} 
    
         #Granting Users with SendAs permissions to the Mailbox.
         ForEach ($Entry in $SendAsAccessUsers ) { 
		     $SG = Get-Recipient -Identity $i.Trustee | ?{$_.RecipientType -ne "UserMailbox" }
	     }
    Echo $CurrentMailbox.PrimarySMTPAddress + "Updated"
}


