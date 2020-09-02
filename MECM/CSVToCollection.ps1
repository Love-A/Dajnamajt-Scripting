# Connect to PS from CM Console and run
Get-Content “C:\temp\Computers.csv” | foreach { Add-CMDeviceCollectionDirectMembershipRule -CollectionId A0100000 -ResourceID (Get-CMDevice -Name $_).ResourceID }
