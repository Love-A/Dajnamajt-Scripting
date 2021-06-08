param (
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$PasswordFile,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$BCUPath
)

# Gather System preferences
$ComputerSystemModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Model
    Write-OutPut "Determined system model is  $ComputerSystemModel. Trying to find matching settingsfile..."

# Set LogPath
    #Construct TSEnv
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop

    #Get Logpath
    $LogPath = $TSEnvironment.Value("_SMSTSLogPath")

#Get ExitCode Info
[XML]$BCUExitCodes = Get-Content ".\BCU_ExitCodes.xml"

# Run BCU and set BIOS Settings
    
    #Set BIOS Variables
    $REPSETFile = "$BCUPath\$ComputerSystemModel.REPSET"
    $CurrentPassword = "$BCUPath\$PasswordFile.bin"
    $LogFile = "$LogPath\$ComputerSystemModel.REPSETLog.log"

        # Run HP BCU Utility and try to create a new REPSET file for device
        $HPBCU = @{
            FilePath = "$BCUPath\BiosConfigUtility64.exe"
            ArgumentList = @(
                "`"/Set:$REPSETFile`"", `
                "`"/cpwdfile:$CurrentPassword`"", `
                "`"/verbose`""
            )
            wait = $True
            PassThru = $True
            RedirectStandardOutput = $LogFile
            WindowStyle = "Hidden"
        }

        $BCUExitCode = (Start-Process @HPBCU).ExitCode

        #Exit and write exitmessage
        $ExitCode = "exit$BCUExitCode"
        $ExitCodeMessage = $BCUExitCodes.exitcodes.$ExitCode
        Write-OutPut $ExitCodeMessage
