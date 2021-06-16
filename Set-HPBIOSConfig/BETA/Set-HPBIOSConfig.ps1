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
        
    The script uses the "config.xml" file to determine the following:
    
    $BCUPath
    UNC Path to the Bios Settings and HP BCU utility
    
    $PasswordFile
    The name of your "Password.bin" file
    
    $RepsetExt
    The fileextension of your BCU Config files, eg .repset or .txt

    To Download HP BIOS Configuration Utility
    https://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html
    
    For more information on the BIOSConfigUtility:
    http://ftp.hp.com/pub/caps-softpaq/cmit/whitepapers/BIOS_Configuration_Utility_User_Guide.pdf


.PARAMETER Config

    Enter the UNCPath to the config.xml file, eg "\\SCCMSERVER\OSD$\Bios Settings\Config.xml"

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config '.\config.xml'

.EXAMPLE
\\SCCMSERVER\BIOS$\Set-HPBIOSConfig.ps1 -Config '\\SCCMSERVER\OSD$\Bios Settings\config.xml'

Updates: 
2021-06-15 --- A bit of rewrite to use a "config.xml" for Script variables instead of script parameters, to make the script static and the only changes needed is in the config.xml
               Added some more Try/catch
               More logging

2021-06-16 --- Added <SetGet> to config.xml file, use this to change if BCU is to "/set" or "/get" BIOS Config. 

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

    Try{
        [XML]$BCUExitCodes = Get-Content "$BCUPath\BCU_ExitCodes.xml" -EA Stop
    }
    Catch{
        $_.Exception.Message ; Exit 1
    }

# Gather System preferences
$ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model

# Set LogPath
    #Construct TSEnv
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop

    #Get Logpath
    $LogPath = $TSEnvironment.Value("_SMSTSLogPath")

# Run BCU and set BIOS Settings
    
    #Set BIOS Variables
    $REPSETFile = "$BCUPath\$ComputerSystemModel$RepsetExt"
        Write-OutPut "Trying to find $REPSETFile..."

    $CurrentPassword = "$BCUPath\$PasswordFile.bin"
        Write-Output "Password.bin file set as $CurrentPassword set..."

    $LogFile = "$LogPath\$ComputerSystemModel.REPSETLog.log"
        Write-output "Output will be logged to $LogFile..."

        # Set HP BCU arguments
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
                Write-Output "Found BCU & Config, will try to config BIOS..."
            }
            Catch{
                $_.Exception.Message ; Exit 1
            }

        #Exit and output exitmessage

        $ExitCode = "exit$BCUExitCode"
        $ExitCodeMessage = $BCUExitCodes.exitcodes.$ExitCode
        Write-OutPut "$BCUExitCode - $ExitCodeMessage"
        Exit $BCUExitCode
