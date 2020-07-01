<# 
.Synopsis
    Changes the Organisation Tattoo of the device

.DESCRIPTION
	Intended to be used with DeviceBranding.ps1
    This script changes the DisplayValue subkey in registry which we create to make a "tattoo" on each device, and there after sort them in ActiveDirectory and SCCM (collections etc)
	
.PARAMETER Organisation
    This is the value we will use to set DisplayValue subkey value
	
.PARAMETER CompName
    This parameter is just for show in the Write-Host at the end of each 
	
.EXAMPLE
    PS > Change_Organisation.ps1 -organisation ORG1 -CompName CND1234ABC

#Requires -RunAsAdministrator

.NOTES

	    FileName:  Change_organisation.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2019-03-06  
	
	    Updated:
	

    Version history:

#>


Param(
    [parameter(Mandatory=$true, HelpMessage="Set organisation. Valid choices are ORG1, ORG2")]
    [ValidateNotNullOrEmpty()]
    [string]$Organisation
    )


#RegistryPath to the DisplayValue subkey
$RegistryPath="HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ORGANISATION"    

#Set Organisation to ORG1 and move to the ORG1 OU
  If ($Organisation  -eq 'ORG1')  {

  'Setting organisation to ORG1'
            
            set-ItemProperty -Path $registryPath -Name DisplayVersion -Value ORGANISATION01-W10
    
            # Retrieve DN of local computer.
            $SysInfo = New-Object -ComObject "ADSystemInfo"
            $ComputerDN = $SysInfo.GetType().InvokeMember("ComputerName", "GetProperty", $Null, $SysInfo, $Null)

            # Bind to computer object in AD.
            $Computer = [ADSI]"LDAP://$ComputerDN"

            # Specify target OU.
            $TargetOU = "OU=ORG1,OU=Devices,DC=DOMAIN,DC=DOMAIN,DC=COM"

            # Bind to target OU.
            $OU = [ADSI]"LDAP://$TargetOU"

            # Move computer to target OU.
            $Computer.psbase.MoveTo($OU)

            Write-Host Device with name $env:ComputerName has been moved.
    
    Invoke-WMIMethod -ComputerName $env:ComputerName -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule “{00000000-0000-0000-0000-000000000002}”> $Null
	
	#Set Organisation to ORG2 and move to the ORG2 OU
  }  ElseIf ($Organisation  -eq 'ORG2')  
  
    If ($Organisation  -eq 'ORG2')  {

  'Setting organisation to ORG2'
            
            set-ItemProperty -Path $registryPath -Name DisplayVersion -Value ORGANISATION02-W10
    
            # Retrieve DN of local computer.
            $SysInfo = New-Object -ComObject "ADSystemInfo"
            $ComputerDN = $SysInfo.GetType().InvokeMember("ComputerName", "GetProperty", $Null, $SysInfo, $Null)

            # Bind to computer object in AD.
            $Computer = [ADSI]"LDAP://$ComputerDN"

            # Specify target OU.
            $TargetOU = "OU=ORG2,OU=Devices,DC=DOMAIN,DC=DOMAIN,DC=COM"

            # Bind to target OU.
            $OU = [ADSI]"LDAP://$TargetOU"

            # Move computer to target OU.
            $Computer.psbase.MoveTo($OU)

            Write-Host Device with name $env:ComputerName has been moved.
    
    Invoke-WMIMethod -ComputerName $env:ComputerName -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule “{00000000-0000-0000-0000-000000000002}”> $Null

  }  Else {

  'You have not supplied a valied organisation'

}
