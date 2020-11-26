$params = @{
    ProviderName = 'User32'
    MaxEvents    = 10
}
$Servers = @(
"SERVERNAME"
)

Foreach($Server in $Servers){
    Try{
        Write-Output "Fetching events for $Server"
        Get-WinEvent -ComputerName $Server @params | Select-Object TimeCreated,Message | Out-File -Width ([int]::MaxValue-1) C:\Temp\Event1074.txt -Append
    }
        Catch{Write-Output "Could not connect to $Server..."}
}  
