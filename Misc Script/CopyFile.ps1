Param(
[parameter(Mandatory = $true, HelpMessage = "Ange filen eller katalogen du vill kopiera.")]
[ValidateNotNullOrEmpty()]
[String]$FileCopy = "",

[parameter(Mandatory = $true, HelpMessage = "Ange vart du vill kopiera till.")]
[ValidateNotNullOrEmpty()]
[String]$FileDestination = ""

)

New-Item -Path $FileDestination -Name $env:COMPUTERNAME -ItemType "Directory"
Copy-Item $FilePath -Destination $FileDestination\$env:COMPUTERNAME