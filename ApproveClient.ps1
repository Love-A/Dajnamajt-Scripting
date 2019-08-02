<#
.SYNOPSIS
	Approves device records in set collection
	
.DESCRIPTION
	Script will approve all devices in a set collection, of array of collections.
	Script created Peter van der Woude, https://www.petervanderwoude.nl/post/approve-block-unapprove-or-unblock-a-client-in-configmgr-2012-via-powershell/

	"In WMI there is the class SMS_Collection, which has the methods ApproveClients and BlockClients. 
	These methods can be used to (un)approve and (un)block clients and they require both the same two parameters. They both require a boolean and an array as input. 
	When the boolean is set to TRUE it will approve, or block, all the clients specified in the array and when the boolean is set to FALSE it will unapprove, or unblock, all the clients in the specified array." 
	

.NOTES

	    FileName: 
	  
	    Author: Peter van der Woude
	
	    Contact:
	
	    Created:     
	
	    Updated:
	

    Version history:
#>
function Approve-Client
{
	param ([string]$SiteCode="",
		[string]$SiteServer="",
		[string]$CollectionName="")
	
	$ClientsArray = @()
	
	$CollectionId = (Get-WmiObject -Class SMS_Collection `
								   -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer `
								   -Filter "Name='$CollectionName'").CollectionId
	$ClientsArray = (Get-WmiObject -Class SMS_CollectionMember_a `
								   -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer `
								   -Filter "CollectionId='$CollectionId'").ResourceId
	
	Invoke-WmiMethod -Namespace root/SMS/site_$($SiteCode) `
					 -Class SMS_Collection -Name ApproveClients `
					 -ArgumentList @($False, $ClientsArray) -ComputerName $SiteServer
}

Approve-client

