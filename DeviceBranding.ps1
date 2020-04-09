<# 
.Synopsis
    Device Branding

.DESCRIPTION
    
	I made this simple device branding script to be used with "ConfigMgr OSD FrontEnd" by Nickolaj Andersen, , it will brand your device depending on which OU the device is placed.
	You could probably customize it to work without it aswell, but this one uses the "OSDDomainOUName" -variable that the FrontEnd creates to set where the device should be joined during OSD. 
	This script will create a set of registry keys which will look like an installed application, which you later can use for example collection building and/or device targeting in SCCM.
	As it is, this script is supposed to be used during OSD in an Task Sequence.

	At line 47, 49, 51, 55, edit the "ORGANISATION" to fit your needs
	
.NOTES

	    FileName: DeviceBranding.ps1
	  
	    Author: Love Arvidsson
	
	    Contact: Love.Arvidsson@norrkoping.se
	
	    Created: 2019-07-19
	
	    Updated: 2020-04-06

    Version history: 
    
    1.0 ... 2019-07-19 - Script Created
    1.1 ... 2020-04-06 - Set the branding based on $ORG value instead of $OU value as we never changed to the new FrontEnd which used the $OU variable.
    1.2 ... 2020-04-09 - Removed the Switch and just let the $ORG decide brandning.

#>

#Construct TSEnvironment object
try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch [System.Exception] {
    Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object" ; exit 3
}

#Get ORG variable value to determine switch
$ORG = $TSEnvironment.Value("ORG")

# Get OSDComputerName variable value
$OSDComputerName = $TSEnvironment.Value("OSDComputerName")

#Get Date
$Date = Get-Date -Format "MM/dd/yyyy"

#Set registry standard
$RegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

        New-Item -Path $RegPath -Name "ORGANISATION"
        
$ValuePath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ORGANISATION" 

        New-ItemProperty -Path $ValuePath -Name "QuietDisplayName" -Value "ORGANISATION" -Type String -Force
        New-ItemProperty -Path $ValuePath -Name "DisplayName" -Value Organisation -Type String
        New-ItemProperty -Path $ValuePath -Name "DisplayVersion" -Value ORGANISATION-W10 -Type String
        New-ItemProperty -Path $ValuePath -Name "UninstallString" -Value N/A -Type String
        New-ItemProperty -Path $ValuePath -Name "Publisher" -Value "ORGANISATION" -Type String
        New-ItemProperty -Path $ValuePath -Name "InstallDate" -Value $Date -Type String
        New-ItemProperty -Path $ValuePath -Name "NoModify" -Value 1 -Type DWord
        New-ItemProperty -Path $ValuePath -Name "NoRepair" -Value 1 -Type DWord
        New-ItemProperty -Path $ValuePath -Name "NoRemove" -Value 1 -Type DWord
            
# Set DisplayVersion branding based on $ORG
set-ItemProperty -Path $ValuePath -Name DisplayVersion -Value $ORG

    Write-Output "$OSDComputerName Branded as $ORG"
            
exit $LASTEXITCODE

