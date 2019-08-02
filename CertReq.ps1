<# 
.Synopsis
    Used to CertReq during OSD

.DESCRIPTION
    This script will and your trusted rootcert and place in the rootstore of the device being installed.
    The root cert needs to be exported and placed in the same directory of the PSScript, then make a package of it.
	Next it will request a new cert based on the template which you have set up.

.NOTES

	    FileName:  Certreq.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2019-06-20 
	
	    Updated:
	

    Version history:

#>

#Enter name of root cert
certutil -f -addstore root ROOTCERTIFICATE.p7b

Start-Sleep -Seconds 5

#Create TS.env
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment

#Set computer name
$Hostname = $tsenv.Value("OSDComputername")

#Create temporary reqfile-data
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

$filecontent = Get-Content "$inf"
$filecontent = $filecontent.replace("%HOSTNAME%", $hostname)

$output_file = "$($working_dir)$($hostname)$(".inf")"
Set-Content -Path $output_file -Value $filecontent

#Enter your CES, CEP And TEMPLATE.
certreq -new $output_file "$($hostname).req"
certreq -submit -Username DOMAIN\USER -p PASSWORD -PolicyServer "CEP" -config "CES" -attrib "CertificateTemplate:TEMPLATE" "$($hostname).req" "$($hostname).cer"
certreq -accept "$($hostname).cer"
