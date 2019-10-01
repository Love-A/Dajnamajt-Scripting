<# 
.Synopsis
    Copy all SMSTSLogs and CCM logs.

.DESCRIPTION
    This script is orginially made by Jörgen Nilsson over att CCMEXEC, https://bit.ly/2o7DaMu.
    I juste made som tweaks to it, so that it can by run in a TS and copy all the logs and remove old logs per client if the already exist.

    Just at a "Run Powershell Script" -step in the task sequence and run this at the end.
    
.NOTES

	    FileName:  CopyCMLogs.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2019-10-01
	
	    Updated:
	

    Version history:

#>

#.EDIT THIS
#Set LogShare path
$Logshare = "\\SharePath\"

#Get path for SCCM client Log files
$Logpath = Get-ItemProperty -path HKLM:\Software\Microsoft\CCM\Logging\@Global
$Log = $logpath.LogDirectory

#Create folders
New-Item -Path $env:temp\SCCMLogs -ItemType Directory -Force
Copy-item -path $log\* -destination $env:temp\Sccmlogs -Recurse -Container -Force

#Create a .zip archive with sccm logs
Compress-Archive -Path $env:temp\Sccmlogs\* -CompressionLevel Optimal -DestinationPath $env:temp\sccmlogs

#Copy zipped logfile to servershare
$ComputerLogShare = $LogShare + “\” + $env:Computername

if (Test-Path $ComputerLogShare)
{
  Remove-Item $ComputerLogShare
}

New-Item -Path $ComputerLogShare -ItemType Directory -Force
Copy-Item $env:temp\sccmlogs.zip -Destination $ComputerLogShare -force

#Cleanup temporary files/folders
Remove-Item $env:temp\SCCMlogs -Recurse
Remove-item $env:temp\SCCMlogs.zip