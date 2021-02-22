<#
	.SYNOPSIS
		This application will load available network-printers from a printserver
	
	.DESCRIPTION
		Use this application to load available network-printers and then add, set as standard or remove from from you computer.
	
	.PARAMETER Printserver
		Just add the name of the printserver eg "Printserver01"

    .NOTES
	    FileName:  Add-Networkprinter.ps1
	  
	    Author:  Love Arvidsson
	
	    Contact:  Love.Arvidsson@norrkoping.se
	
	    Created:   2020-06-30
	
	    Updated:
	

    Version history:
        1.0 - (2020-06-30) Script Created
	1.1 - (2020-09-17) Added support for multiple printservers
	1.2 - (2021-02-22) Added Status and Location tabs
			Added some error handling for adding and removeing printer
    			Fixed a bug where i had not taken into account for multiple printservers and updating the "Availible printers list" would only return results from one of the server.
#>

#======================================
#region Load Pre-req

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#endregion
#======================================

#======================================
#region VisualStudio XAML
$InputXML = @"
<Window x:Name="MainForm" x:Class="Install_Printer.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Install_Printer"
        mc:Ignorable="d"
        Height="560" Width="755" Topmost="True" ResizeMode="NoResize" WindowStartupLocation="CenterScreen" UseLayoutRounding="True" Title="Add Printer">
    <Grid Margin="0,0,0,1" UseLayoutRounding="True">
        <Button x:Name="AddPrinter" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" Margin="565,60,0,0" Height="30" FontWeight="Bold" UseLayoutRounding="True">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <Button x:Name="RemovePrinter" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" Margin="565,360,0,0" Height="30" FontWeight="Bold" UseLayoutRounding="True">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <Button x:Name="SetStdPrinter" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" Margin="565,300,0,0" Height="30" FontWeight="Bold" UseLayoutRounding="True">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <Button x:Name="PrintTestpage" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" Margin="565,420,0,0" Height="30" FontWeight="Bold" UseLayoutRounding="True">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <Button x:Name="UpdateList" HorizontalAlignment="Left" VerticalAlignment="Top" Width="150" Margin="565,120,0,0" Height="30" FontWeight="Bold" UseLayoutRounding="True">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <TextBox x:Name="ServiceDeskText" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="405" Margin="10,498,0,0" FontStyle="Italic" BorderThickness="0" IsReadOnly="True"/>
        <Button x:Name="MailTo" HorizontalAlignment="Left" VerticalAlignment="Top" Width="166" Margin="414,497,0,0" Background="White" BorderBrush="Black" FontStyle="Italic" BorderThickness="0" FontWeight="Bold" HorizontalContentAlignment="Left"/>
        <TextBox x:Name="AvailablePrintersText" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="530" Margin="10,11,0,0" BorderThickness="0" IsReadOnly="True"/>
        <ListView x:Name="PrinterBox" HorizontalAlignment="Left" Height="186" VerticalAlignment="Top" Width="525" Margin="10,39,0,0" SelectionMode="Single" Background="#FFFBFBFB" UseLayoutRounding="True" ClipToBounds="True" BorderThickness="1">
            <ListView.Effect>
                <DropShadowEffect BlurRadius="1" Opacity="0.6" ShadowDepth="1"/>
            </ListView.Effect>
            <ListView.View>
                <GridView AllowsColumnReorder="False">
                    <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding 'Name'}" Width="260"/>
                    <GridViewColumn Header="Status" DisplayMemberBinding ="{Binding 'PrinterStatus'}" Width="70"/>
                    <GridViewColumn Header="Server" DisplayMemberBinding ="{Binding 'ComputerName'}" Width="95"/>
                    <GridViewColumn Header="Location" DisplayMemberBinding ="{Binding 'Location'}" Width="460"/>
                </GridView>
            </ListView.View>
        </ListView>
        <TextBox x:Name="AddedPrintersText" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="525" Margin="10,257,0,0" BorderThickness="0" IsReadOnly="True"/>
        <ListView x:Name="AddedPrintersBox" HorizontalAlignment="Left" Height="190" VerticalAlignment="Top" Width="525" Margin="10,285,0,0" SelectionMode="Single" Background="#FFFBFBFB" UseLayoutRounding="True" BorderThickness="1" ClipToBounds="True">
            <ListView.View>
                <GridView AllowsColumnReorder="False">
                    <GridViewColumn Header="Name" DisplayMemberBinding ="{Binding 'Name'}" Width="335"/>
                    <GridViewColumn Header="Status" DisplayMemberBinding ="{Binding 'PrinterStatus'}" Width="70"/>
                </GridView>
            </ListView.View>
        </ListView>
    </Grid>
</Window>
"@

$inputXML = $inputXML -replace '\s{1}[\w\d_-]+="{x:Null}"', ''
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
$inputXML = $inputXML -replace 'TextChanged="[\w\d-]+\w"', ''
$inputXML = $inputXML -replace 'SelectionChanged="[\w\d-]+\w"', ''
$inputXML = $inputXML -replace ' Selected="[\w\d-]+\w"', ''
$inputXML = $inputXML -replace ' Click="[\w\d-]+"', ''
$inputXML = $inputXML -replace 'Checked="CheckBox_Checked" ', ''
$inputXML = $inputXML -replace 'Checked="RadioButton_Checked" ', ''

[xml]$xaml = $inputXML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try
{
	$Form = [Windows.Markup.XamlReader]::Load($reader)
}
catch
{
	Write-Warning $_.Exception
	throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
	try
	{
		Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop
	}
	catch { throw }
}
#endregion VS XAML
#======================================

#======================================
#region Load XAML Objects In PowerShell
Function Get-FormVariables
{
	if ($global:ReadmeDisplay -ne $true) { Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow; $global:ReadmeDisplay = $true }
	write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
	get-variable WPF*
}

Get-FormVariables
#endregion Load XAML Objects In PowerShell
#======================================

#======================================
#region Standard Parameters

# Set Printserver eg "Printserver01","Printserver02"
	$PrintServers = @(
	""
	)

# Set TextBox text
    $WPFAvailablePrintersText.Text = 'Available Printers'
    $WPFAddedPrintersText.Text = 'Installed Printers'
    $WPFServiceDeskText.text = 'Need help? Call Servicedesk on 011-xxxxxxx'

# Set Button Text
    $WPFAddPrinter.Content = 'Add Printer'
    $WPFSetStdPrinter.Content = 'Set as standard printer'
    $WPFRemovePrinter.Content = 'Remove printer'
    $WPFPrintTestPage.Content = 'Print testpage'
    $WPFUpdateList.Content = 'Update List'

#Protected Printers
    $ProtectedPrinters = (
    "Fax",
    "Microsoft XPS Document Writer",
    "Microsoft Print to PDF"
    )

#endregion
#======================================

#======================================
#region Available Printers

# Get Available printers.

$Printers = ForEach($PrintServer in $PrintServers){
Get-Printer -ComputerName $PrintServer | Sort-Object
}
$WPFPrinterBox.ItemsSource = $Printers

# Install selected printer
$WPFAddPrinter.Add_Click({
		$PrinterName = $WPFPrinterBox.SelectedItem.name
        $Printserver = $WPFPrinterBox.SelectedItem.ComputerName
		    $msgBoxInput = [System.Windows.MessageBox]::Show("$PrinterName kommer att installeras på din dator", 'Lägg till skrivare', 'YesNo')
		        Switch ($msgBoxInput){
				'Yes'{ 
                        	try{
				    Add-Printer -ConnectionName \\$Printserver\$PrinterName -EA Stop
				    $msgBoxInput = [System.Windows.MessageBox]::Show("$PrinterName has been added to your computer", 'Add Printer', 'OK')}
                        	catch{
				    $msgBoxInput = [System.Windows.MessageBox]::Show("$PrinterName Could not be added.", 'Add Printer', 'OK')
				    $msgBoxInput = [System.Windows.MessageBox]::Show("$_.", 'Add Printer', 'OK')
				    Break
				    }
			    	}
		            }
		    $WPFAddedPrintersBox.Clear()
            $WPFAddedPrintersBox.ItemsSource = Get-Printer | Sort-Object       
	})



#Update list
$WPFUpdateList.Add_click({
		Get-WmiObject Win32_LogonSession | Where-Object { $_.AuthenticationPackage -eq 'Kerberos' } | ForEach-Object { klist.exe purge }
		Invoke-Command{
			$cmd1 = "cmd.exe"
			$arg1 = "/c"
			$arg2 = "gpupdate /target:user /force /wait:0"
			&$cmd1 $arg1 $arg2
		}

		$WPFPrinterBox.Clear()
		$Printers = ForEach ($PrintServer in $PrintServers)
		{
			Get-Printer -ComputerName $PrintServer | Sort-Object
		}

		$WPFAddedPrintersBox.Clear()
		$WPFAddedPrintersBox.ItemsSource = Get-Printer | Sort-Object
	})

#endregion Availabel Printers
#======================================

#======================================
#region Added Printers

# Get Added printers
$WPFAddedPrintersBox.ItemsSource = Get-Printer | Sort-Object

# Set selected printer as standard
$WPFSetStdPrinter.Add_Click({
        $StdPrinter = $WPFAddedPrintersBox.SelectedItem.Name
            $StdPrinterServer = $WPFAddedPrintersBox.SelectedItem.ComputerName
                $SetStdPrinter = $StdPrinter -Replace [RegEx]::Escape("\\$StdPrinterServer\")
                    $printer = Get-CimInstance -Class Win32_Printer -Filter "ShareName='$SetStdPrinter'"
                        Invoke-CimMethod -InputObject $printer -MethodName SetDefaultPrinter
		                    $msgBoxInput = [System.Windows.MessageBox]::Show("$StdPrinter is now set as the standard printer", 'Standard printer', 'OK')
		                        Switch ($msgBoxInput){
			                        'OK'{}
		                        }
	})

# Remove selected printer
$WPFRemovePrinter.Add_Click({
		$PrintName = $WPFAddedPrintersBox.SelectedItem.Name
           		If ($PrintName -notin $ProtectedPrinters)
		{
			$msgBoxInput = [System.Windows.MessageBox]::Show("Are you sure you want to remove $PrintName", 'Remove Printer', 'YesNo')
			Switch ($msgBoxInput)
			{
				'yes'{
					Try
					{
						$PrintRemove = Get-Printer -name $PrintName
						Remove-Printer -InputObject $PrintRemove -EA Stop
					}
					Catch
					{
						$msgBoxInput = [System.Windows.MessageBox]::Show("Could not remove printer", 'Remove printer', 'OK')
						$msgBoxInput = [System.Windows.MessageBox]::Show("$_", 'Remove Printer', 'OK')
						Break
					}
					$msgBoxInput = [System.Windows.MessageBox]::Show("Printer Removed", 'Remove printer', 'OK')
				}
			}
			$WPFAddedPrintersBox.Clear()
			$WPFAddedPrintersBox.ItemsSource = Get-Printer | Sort-Object
		}
		else
		{
			$msgBoxInput = [System.Windows.MessageBox]::Show("This printer can not be removed", 'Remove printer', 'OK')
		}
	})

#Print Test Page
$WPFPrintTestPage.Add_Click({
        $PrintName = $WPFAddedPrintersBox.SelectedItem.Name
            $PrinterInstance = [wmi]"\\.\root\cimv2:Win32_Printer.DeviceID='$PrintName'"
                $PrinterInstance.PrintTestPage()
                    $msgBoxInput = [System.Windows.MessageBox]::Show("Testpage has been sent to $PrintName", 'Print testpage', 'OK')


})

#endregion Added Printers
#======================================

# Load Form
[void]$Form.ShowDialog()
