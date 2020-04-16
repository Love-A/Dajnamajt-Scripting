<# 
.Synopsis
    Set HP BIOS Config

.DESCRIPTION
    This will use the gathered BIOS config file from HP BiosConfigUtility and set your systems BIOS preferences.
    Make sure your settings file is named the same as your Win32_ComputerSystem property Model, eg "HP ZBook 15 G4.txt" as the script will call this WMI Class to match up with a settigsfile.
    
    Script expects these files to be in the same directory as BiosConfigUtility64.exe :
        Passwordfile.bin
        BiosConfigUtility64.exe
        BIOSSettings.txt

    Can be made into a package and ran through TS or as application, or even better is to place it on a share accessible from clients, then you wont have to update the package/application-files when making changes in settingsfiles or adding new ones.
    When running this from a UNC-path, you have to do this post your Apply Networksettings -step, as the TS is run in SYSTEM context.
    For Offline-media or package, make sure to set the parameters accordingly.

    To Download HP BIOS Configuration Utility
    https://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html

    For more information on the BIOSConfigUtility:
    http://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/BIOS_Configuration_Utility_User_Guide.pdf

.PARAMETER PasswordFile
    Used to define the name of your Password.bin

    For local or package set:
    eg ".\password.bin" 

.PARAMETER BiosConfigUtility
    Used to define the path to your BiosConfigUtility directory, which should also contain you password.bin and biossettings.txt -files.

    For local or package set:
    ".\BiosConfigUtility64.exe"

.PARAMETER DeploymentType
    To specify if script is ran in TS or in OS to determine loglocation.

.EXAMPLE 1 When using UNC
    PS > .\Set-HPBiosConfig.ps1 -BiosConfigUtility "\\SCCMSERVER\SOURCES\OSD\BIOSconfigUtility64.exe" -PasswordFile "Password.bin" -DeploymentType "OS"

.EXAMPLE 2 Running local or package
    PS > .\Set-HPBiosConfig.ps1 -BiosConfigUtility ".\BiosConfigUtility64.exe" -PasswordFile "Password.bin" -DeploymentType "TS"



.NOTES

	    FileName:  Set-HPBiosConfig.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2020-02-24
	
	    Updated:
	

    Version history:
        
        1.0 - (2020-02-24) Script Created
        1.1 - (2020-04-16) Added some logging and a switch to determine exitcode

#>

param (

	[parameter(Mandatory = $true, HelpMessage = "Set the Password.bin name")]
	[ValidateNotNullOrEmpty()]
	[string]$PasswordFile,

	[parameter(Mandatory = $True, HelpMessage = "Used to set logpath, valid option 'OS' for use in full OS or 'TS' when used during TS/OSD ")]
	[ValidateNotNullOrEmpty()]
	[string]$Deploymenttype,

	[parameter(Mandatory = $true, HelpMessage = "Set path to the BiosConfigUtility64.exe, which also should contain your Password.bin and settings.txt file ")]
	[ValidateNotNullOrEmpty()]
	[string]$BiosConfigUtility

)

# Gather System preferences

    $ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model
    
    # Used if you run local or package.
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# Set Logpath

	switch ($Deploymenttype) {
		'OS'{
		    $LogPath = Join-Path -Path $env:SystemRoot -ChildPath 'Temp'
		}
        'TS'{
            # Construct TSEnvironment object
            try {
                $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
            }
            catch [System.Exception] {
                Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object" ; exit 3
            }

	        # Get Logpath
            $LogPath = $TSEnvironment.Value("_SMSTSLogPath")

        }
    }

# Run the BiosConfigUtility and set BIOS settings

  $BiosConfig = (Start-Process $BIOSConfigUtility -ArgumentList /Set:"`"$ComputerSystemModel.txt`"", /cpwdfile:"`"$PasswordFile`"", /verbose -Wait -Passthru -RedirectStandardOutput $LogPath\BiosSettingsUpdate.log -WindowStyle hidden).ExitCode
  
# Exit Script based on ExitCode from BCU

  Switch ($Biosconfig){
       "0"{
       Write-Output "Bios Config set $ComputerSystemModel. For more information see log at $LogPath\BiosSettingsUpdate.log..." 
       Exit 0
       }

       "1" {
       Write-Warning "Not Supported WMI result code – Setting is not supported on system."
       Exit 1
       }

       "2" {
       Write-Warning "Unknown WMI result code – Operation failed for unknown reason."
       Exit 2
       }

       "3" {
       Write-Warning "Timeout WMI result code – Operation timed out."
       Exit 3
       }

       "4" {
       Write-Warning "Failed WMI result code – Operation failed."
       Exit 4
       }

       "5" {
       Write-Warning "Invalid Parameter WMI result code – A parameter is missing or wrong type."
       Exit 5
       }

       "6" {
       Write-Warning "Access Denied WMI result code – Setting modification failed due to BIOS permissions."
       Exit 6
       }

       "10" {
       Write-Warning "Valid password not provided. BCU was unable to find a valid password on the command-line."
       Exit 10
       }

       "11" {
       Write-Warning "Config file not valid. BCU was unable to locate the configuration file or unable to read the file at the specified path."
       Exit 11
       }

       "12" {
       Write-Warning "First line in config file is not the keyword 'BIOSConfig.' First line in the configuration file must be the word BIOSConfig followed by the file format version, currently 1.0."
       Exit 12
       }

       "13" {
       Write-Warning "Failed to change setting. BCU failed to change one or more settings. For more information see log at $LogPath\BiosSettingsUpdate.log..."
       Exit 13
       }

       "14" {
       Write-Warning "Unable to write to file or system. BCU was unable to connect to HP BIOS WMI. WMI classes are corrupted or the system is not supported."
       Exit 14
       }

       "16" {
       Write-Warning "BCU was unable to connect to HP BIOS WMI. WMI classes are corrupted or the system is not supported."
       Exit 16
       }

       "30" {
       Write-Warning "Password file error. Unable to read or decrypt the password file."
       Exit 30
       }

   }
