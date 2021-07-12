<#.DESCRIPTION
    This script will use the gathered BIOS config file from HP BiosConfigUtility and set your systems BIOS preferences. 
    A BIOS Settings file can have .REPSET or .txt filextension.
    Make sure your settings file is named the same as your Win32_ComputerSystem property Model, 
    eg "HP ZBook 15 G4.REPSET" as the script will call this WMI Class to match up with a settigsfile.
    
    Script expects these files to be in the same directory as BiosConfigUtility64.exe :
        Passwordfile.bin
        BiosConfigUtility64.exe
        BIOSSettings.REPSET (or .txt)

    To Download HP BIOS Configuration Utility
    https://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html
    
    For more information on the BIOSConfigUtility:
    http://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/BIOS_Configuration_Utility_User_Guide.pdf


.PARAMETER Config

    Enter the UNCPath to the config.json file, eg "\\SCCMSERVER\OSD$\Bios Settings\Config.json"

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config .\config.json

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config \\SCCMSERVER\OSD$\Bios Settings\config.json



#>

param(
    [Parameter(HelpMessage = 'UNC-Path to JSON Configuration File', Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
    [ValidatePattern('.json')]
    [string]$Config
)

#Get config and BCU ExitCodes from .JSON

Try {
    $ScriptConfig = Get-Content $Config | ConvertFrom-Json
}
Catch {
    $_.Exception.Message
}

$BCUPath = $ScriptConfig.ScriptConfig.HPBCUPath
$PasswordFile = $ScriptConfig.ScriptConfig.PWDFileName
$RepsetExt = $ScriptConfig.ScriptConfig.FileExt
$SetGet = $ScriptConfig.ScriptConfig.SetGet
$GetPath = $ScriptConfig.ScriptConfig.GetPath


# Gather System preferences
$ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model

#Construct TSEnv
if ($SetGet -eq "set") {
    Try {
        $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Continue 
        Write-Output "Task Sequence Variables loaded"
    }
    Catch {
        $_.Exception.Message
        Write-Output "Task Sequence Variables not loaded, assuming run in full OS, outside of task sequence environment.."
        $TSEnvironment = $null
    }
}
    
#Set BIOS Variables
If ($SetGet -eq "Set") {
    If ($TSEnvironment -ne $null) {
        $LogPath = $TSEnvironment.Value("_SMSTSLogPath")
    }
    else {
        $LogPath = "$env:windir\CCM\Logs"
    }
    $REPSETFile = "$BCUPath\$ComputerSystemModel$RepsetExt"
    Write-Output "Trying to find $REPSETFile..."
    $LogFile = "$LogPath\$ComputerSystemModel.REPSETLog.log"
    Write-Output "Output will be logged to $LogFile..."
}
Else {
    $REPSETFile = "$GetPath\$ComputerSystemModel.GET$RepsetExt"
    Write-Output "Config file will be saved as $REPSETFILE..."
    $LogFile = "$GetPath\$ComputerSystemModel.REPSETCreate.log"
    Write-Output "Output will be logged to $LogFile..."
}

$CurrentPassword = "$BCUPath\$PasswordFile.bin"
Write-Output "Password.bin file set as $CurrentPassword set..."
    

# Set HP BCU arguments for BCU cmdline
$HPBCU = @{
    FilePath               = "$BCUPath\BiosConfigUtility64.exe"
    ArgumentList           = @(
        "`"/$SetGet`:$REPSETFile`"", `
            "`"/cpwdfile:$CurrentPassword`"", `
            "`"/verbose`""
    )
    wait                   = $True
    PassThru               = $True
    RedirectStandardOutput = $LogFile
    WindowStyle            = "Hidden"
}

# Run HP BCU
Try {
    if ($SetGet -eq "set") {
        Write-Output "HP BCU Parameters set, will try to config BIOS..."
    }
    else {
        Write-Output "Will create HP BIOS config file..."
    }
	$BCUExitCode = (Start-Process @HPBCU).ExitCode
}
Catch {
    $_.Exception.Message ; Exit 1
}

#Exit and write exitmessage
Write-OutPut "$($ScriptConfig.ExitCodes.$BCUExitCode)"
Exit $BCUExitCode
