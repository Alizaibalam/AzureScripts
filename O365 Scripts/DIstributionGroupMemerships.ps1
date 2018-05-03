$Mailbox=get-Mailbox user@domain.com
$DN=$mailbox.DistinguishedName
$Filter = "Members -like ""$DN"""
Get-DistributionGroup -ResultSize Unlimited -Filter $Filter