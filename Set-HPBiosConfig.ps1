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

    For offline set:
    eg "password.bin" 

.PARAMETER BiosConfigUtility
    Used to define the path to your BiosConfigUtility directory, which should also contain you password.bin and biossettings.txt -files.

    For offline set:
    ".\BiosConfigUtility64.exe"

.PARAMETER LogPath
    To specify if script is ran in TS or in OS to determine loglocation.

.EXAMPLE 1 When using UNC
    PS > .\Set-BiosConfig.ps1 -BiosConfigUtility \\SCCMSERVER\SOURCES\OSD\BIOSconfigUtility64.exe -PasswordFile "Password.bin" -LogPath "OS"

.EXAMPLE 2 Running local or package
    PS > .\Set-HPBiosConfig.ps1 -PasswordFile Password.bin -LogPath TS -BiosConfigUtility .\BiosConfigUtility64.exe



.NOTES

	    FileName:  Set-HPBiosConfig.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2020-02-24
	
	    Updated:
	

    Version history:
        
        1.0 - (2020-02-24) Script Created

#>

param (

	[parameter(Mandatory = $true, HelpMessage = "Set the Password.bin name")]
	[ValidateNotNullOrEmpty()]
	[string]$PasswordFile,

	[parameter(Mandatory = $True, HelpMessage = "Used to set logpath, valid option 'OS' for use in full OS or 'TS' when used during TS/OSD ")]
	[ValidateNotNullOrEmpty()]
	[string]$LogPath,

	[parameter(Mandatory = $true, HelpMessage = "Set path to the BiosConfigUtility64.exe, which also should contain your Password.bin and settings.txt file ")]
	[ValidateNotNullOrEmpty()]
	[string]$BiosConfigUtility

)

# Gather System preferences

    $ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model
    
    # Used if you choose to not use a share, or when run on Offline-media.
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# Set Logpath

	switch ($LogPath) {
		"OS" {
			$LogsDirectory = Join-Path -Path $env:SystemRoot -ChildPath "Temp"
		    }
        Else{
	        $LogsDirectory = $Script:TSEnvironment.Value("_SMSTSLogPath")
            }
    }

# Run the BiosConfigUtility and set BIOS settings

    (Start-Process $BIOSConfigUtility -ArgumentList /Set:"`"$ComputerSystemModel.txt`"", /cpwdfile:"`"$PasswordFile`"", /verbose -Wait -Passthru -RedirectStandardOutput $LogsDirectory\BiosSettingsUpdate.log -NoNewWindow).ExitCode
