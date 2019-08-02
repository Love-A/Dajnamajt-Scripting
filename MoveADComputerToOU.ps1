<# 
.Synopsis
    Used to move the ComputerObject between OU's

.DESCRIPTION
    This script is intended to be used with "ConfigMgr Webservice" and "ConfigMgr OSD FrontEnd" by Nickolaj Andersen. 
    It uses a custom function to move the computer object between OU's in the Active Directory.
    I relies on the "OSDDomainOUName" -variable which is set with diffrent LDAP-path's when you choose directory in the FrontEnd.

.NOTES

	    FileName:  MoveADComputerToOU.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2019-07-29 
	
	    Updated:
	

    Version history:

#>
 
 # Variables
$SecretKey = "<ENTER SECRET KEY>"

# Construct TSEnvironment object
try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object" ; exit 3
}

# Get OSDComputerName variable value
$OSDComputerName = $TSEnvironment.Value("OSDComputerName")

# Set OU
$OU = $TSEnvironment.Value("OSDDomainOUName")

# Construct web service proxy
try {
    $URI = "http://server.domain.com/ConfigMgrWebService/ConfigMgr.asmx"
    $WebService = New-WebServiceProxy -Uri $URI -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "An error occured while attempting to calling web service. Error message: $($_.Exception.Message)" ; exit 2
}

# Move computer to new organization unit
$Invocation = $WebService.SetADOrganizationalUnitForComputer($SecretKey, $OU, $OSDComputerName)
switch ($Invocation) {
    $true {
        exit 0
    }
    $false {
        exit 1
    }
}
