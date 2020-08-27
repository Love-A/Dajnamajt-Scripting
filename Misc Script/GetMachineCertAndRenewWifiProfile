## Set Attributes

    $Hostname = $env:ComputerName
    $ProfileName = ''
    $RootCertName = ''
    $CEP = ''
    $CES = ''
    $CertTemplate = ''
    $XMLProfile = ''

    ## Credentials
        
        $CACertReqUser = ""
        $CACertReqPassword = ""

## Check and remove Previous Wifi-profile if exist
    $WifiProfile = (netsh wlan Show profiles)
    If ($WifiProfile -match '$ProfileName'){
		netsh wlan delete profile ProfileName
    }

    ## Add Rootcert to rootstore
    (certutil -f -addstore root "`"$RootCertName`"")
	    Start-Sleep -Seconds 5


## Create RequestFile
$file = @"
[NewRequest]
Subject="CN=%HOSTNAME%"
KeyLength=2048
KeySpec=1
MachineKeySet=TRUE
SMIME=FALSE

[RequestAttributes]

"@


	$inf = [System.IO.Path]::GetTempFileName()
	Set-Content -Path $inf -Value $file

		$filecontent= Get-Content "$inf"
		$filecontent = $filecontent.replace("%HOSTNAME%",$hostname)

			$output_file = "$($working_dir)$($hostname)$(".inf")"
			Set-Content -Path $output_file -Value $filecontent

## Request new machine cert
	certreq -new $output_file "$($hostname).req"
	certreq -submit -Username $CACertReqUser -p $CACertReqPassword -PolicyServer $CEP -config $CES -attrib CertificateTemplate:$CertTemplate "$($hostname).req" "$($hostname).cer"
	certreq -accept "$($hostname).cer"

## Add NRK1X Wifi Profile
	netsh WLAN add profile filename="$XMLProfile"

## Remove machine cert request file and cert
	Remove-Item .\$Hostname* -Force
    Remove-Item .\$Hostname* -Force

        ## Purge Variables
        $CACertReqUser = $null
        $CACertReqPassword = $null
