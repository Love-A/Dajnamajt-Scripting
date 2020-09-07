<#
If you want to use this script and also update with it, you can add:

"Get-ChildItem "UNCPath to driver" -recurse -filter "*inf" | ForEach-Object {PNPUtil.exe /add-driver $_.FullName /install}""
At the "update needed" section.

Just download the appropriate drivers from intel, unpack and place them at an network location when clients can reach them.

#>

# Get Wi-Fi NIC properties
$NetAdapter = get-netadapter -Physical -Name "Wi-Fi" | Select-Object -Property DriverVersion, InterfaceDescription
    $NetAdapterHW = $NetAdapter | Select-Object -ExpandProperty InterfaceDescription
        $NetAdapterDriver = $NetAdapter | Select-Object -ExpandProperty DriverVersion

    # Compare NIC Driver Version
    Switch($NetAdapterHW){
        "Intel(R) Wireless-AC 9260 160MHz"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Wireless-AC 9260"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Wireless-AC 9560 160MHz"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Wireless-AC 9560"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Dual Band Wireless-AC 8260"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Dual Band Wireless-AC 8265"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('20.70.0.5')
        }
        "Intel(R) Dual Band Wireless-AC 7265"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('18.33.13.4')
        }
        "Intel(R) Dual Band Wireless-AC 7260"{
        $DriverVersion = [Version]::Parse($NetAdapterDriver) -ge [version]::Parse('18.33.13.4')
        }
    }

        # Check if NIC update is needed
        Switch($NetAdapterHW){

            "Intel(R) Wireless-AC 9260 160MHz"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Wireless-AC 9260"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Wireless-AC 9560 160MHz"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Wireless-AC 9560"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Dual Band Wireless-AC 8260"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Dual Band Wireless-AC 8265"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Dual Band Wireless-AC 7265"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            "Intel(R) Dual Band Wireless-AC 7260"{
                if($DriverVersion -eq "True"){
                    Write-output "No Update needed..."
                    }
                Else{
                    Write-Output "Update needed..."
                }
            }

            Default{
            Write-Output "No Intel Wi-Fi NIC present..."
            }
        }
