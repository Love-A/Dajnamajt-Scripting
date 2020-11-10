# Set Parameters
Param(
    [parameter(Mandatory = $true, HelpMessage = "Ange IP eller FQDN till den server som ska testas.")]
    [ValidateNotNullOrEmpty()]
    [String]$Server = "",

    [parameter(Mandatory = $True, HelpMessage = "Ange den Port eller Portar du vill testa.")]
    [ValidateNotNullOrEmpty()]
    [int[]]$Ports = ""
)
    # Get Current IPV4 Address
        $CurrentIPV4 = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred -PrefixOrigin Dhcp | Select-Object -ExpandProperty IPAddress

# Test port connections
    Foreach ($Port in $Ports){
         Try{
            $Socket = new-object Net.Sockets.TcpClient
            $Socket.Connect($Server,$Port)
            $Test = $Socket.Connected
                If($Test -eq $true){
                Write-Output "Connected to $Server over port $Port"
                }
            }
        Catch{"Could not connect to $Server over port $Port"}
    }
    
    # Write IPV4 Address
        Write-Output "Current client ipv4 addresss $CurrentIPV4"
