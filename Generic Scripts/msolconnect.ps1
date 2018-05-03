Set-ExecutionPolicy Unrestricted –Scope CurrentUser
$UserCredential = Get-Credential
Import-Module MSOnline
Connect-MsolService –Credential $UserCredential
