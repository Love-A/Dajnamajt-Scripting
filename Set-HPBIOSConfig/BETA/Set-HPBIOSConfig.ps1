<#.DESCRIPTION
    This script will use the gathered BIOS config file from HP BiosConfigUtility and set your systems BIOS preferences. 
    A BIOS Settings file can have .REPSET or .txt filextension.
    Make sure your settings file is named the same as your Win32_ComputerSystem property Model, 
    eg "HP ZBook 15 G4.REPSET" as the script will call this WMI Class to match up with a settigsfile.
    
    Script expects these files to be in the same directory as BiosConfigUtility64.exe :
        Passwordfile.bin
        BiosConfigUtility64.exe
        BIOSSettings.REPSET (or .txt)
        BCU_ExitCodes.xml

    To Download HP BIOS Configuration Utility
    https://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html
    
    For more information on the BIOSConfigUtility:
    http://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/BIOS_Configuration_Utility_User_Guide.pdf


.PARAMETER Config

    Enter the UNCPath to the config.xml file, eg "\\SCCMSERVER\OSD$\Bios Settings\Config.xml"

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config .\config.xml

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config \\SCCMSERVER\OSD$\Bios Settings\config.xml



#>

param(
    [Parameter(HelpMessage='UNC-Path to XML Configuration File', Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    [ValidatePattern('.xml')]
    [string]$Config
    )

#Get XML config and BCU ExitCodes
    Try{
        [XML]$ScriptParam = Get-Content "$Config" -EA Stop
    }
    Catch{
        $_.Exception.Message ; Exit 1    
    }
        #Get ScriptConfig
        $BCUPath = $ScriptParam.Config.HPBCUPath
        $Passwordfile = $ScriptParam.Config.PWDFileName
        $RepsetExt = $ScriptParam.Config.FileExt
        $SetGet = $ScriptParam.Config.SetGet
        $GetPath = $ScriptParam.Config.GetPath

    Try{
        [XML]$BCUExitCodes = Get-Content "$BCUPath\BCU_ExitCodes.xml" -EA Stop
    }
    Catch{
        $_.Exception.Message ; Exit 1
    }

# Gather System preferences
    $ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model

#Construct TSEnv
    if($SetGet -eq "set"){
        Try{
            $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Continue 
            Write-Output "Task Sequence Variables loaded"
            }
        Catch{
			$_.Exception.Message
			Write-Output "Task Sequence Variables not loaded, assuming run in full OS, outside of task sequence environment.."
			$TSEnvironment = $null
		}
    }
    
#Set BIOS Variables
    If($SetGet -eq "Set"){
            If($TSEnvironment -ne $null){
                $LogPath = $TSEnvironment.Value("_SMSTSLogPath")
            }
            else{
                $LogPath = "$env:windir\CCM\Logs"
            }
        $REPSETFile = "$BCUPath\$ComputerSystemModel$RepsetExt"
            Write-Output "Trying to find $REPSETFile..."
        $LogFile = "$LogPath\$ComputerSystemModel.REPSETLog.log"
            Write-Output "Output will be logged to $LogFile..."
    }
    Else{
        $REPSETFile = "$GetPath\$ComputerSystemModel$RepsetExt"
            Write-Output "Config file will be saved as $REPSETFILE..."
        $LogFile = "$GetPath\$ComputerSystemModel.REPSETCreate.log"
            Write-Output "Output will be logged to $LogFile..."
    }

    $CurrentPassword = "$BCUPath\$PasswordFile.bin"
        Write-Output "Password.bin file set as $CurrentPassword set..."
    

# Set HP BCU arguments for BCU cmdline
    $HPBCU = @{
        FilePath = "$BCUPath\BiosConfigUtility64.exe"
        ArgumentList = @(
            "`"/$SetGet`:$REPSETFile`"", `
            "`"/cpwdfile:$CurrentPassword`"", `
            "`"/verbose`""
        )
        wait = $True
        PassThru = $True
        RedirectStandardOutput = $LogFile
        WindowStyle = "Hidden"
    }

# Run HP BCU
    Try{
        $BCUExitCode = (Start-Process @HPBCU).ExitCode
            if($SetGet -eq "set"){
                Write-Output "Found BCU & Config, will try to config BIOS..."
            }
            else{
                Write-Output "Creating config file..."
            }
    }
    Catch{
        $_.Exception.Message ; Exit 1
    }

$ExitCode = "exit$BCUExitCode"
$ExitCodeMessage = $BCUExitCodes.exitcodes.$ExitCode

#Exit and write exitmessage
    Write-OutPut "$BCUExitCode - $ExitCodeMessage"
		Exit $BCUExitCode
