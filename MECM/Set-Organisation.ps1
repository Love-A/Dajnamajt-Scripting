<#
.Synopsis
    This will set the TSValue 'ORG'


.DESCRIPTION
    This is used to set the TSValue 'ORG', used to later in the TS for eg DeviceBranding, specific app installation, or OU transfer.
    To add an organisation to the list you need to populate the $OrgMembers Array with a custom PSObject "[PSCustomObject]@{Name="ORGNAME"; Description="ORGDESCRIPTION"; SetOrg="ORGVALUE"}".
    Just add as many rows you need, one for each Organisation.

    Change:

        Name - Name of the organisation
        Description - a short description of the organisation
        SetOrg - The value used to set TSEnv.Value("ORG")

.NOTES

	    FileName:  Set-Organisation.ps1

	    Author:  Love Arvidsson

	    Contact: Love.Arvidsson@norrkoping.se

	    Created: 2020-05-20

	    Updated:


    Version history:

    1.0 - (2020-05-20) Script created
    2.0 - (2020-07-06) Almost a complete re-write of the script
                        Redesign of GUI
                        Changed how the OrgListView is populated

#>



#region Load Pre-req

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms

    [Windows.Forms.Application]::EnableVisualStyles()

    # Load TS Env
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment

#endregion

#region VisualStudio XAML
#===========================================================================
$InputXML = @"
<Window x:Name="Set_OrgHTA" x:Class="Set_Organisation_New.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        mc:Ignorable="d"
        Title="Välj Organisation" Height="392" Width="689" Topmost="True" ResizeMode="NoResize" WindowStartupLocation="CenterScreen">
    <Grid>
        <Button x:Name="StartInstall" HorizontalAlignment="Left" VerticalAlignment="Top" Width="120" Margin="520,80,0,0" Height="40" FontWeight="Bold">
            <Button.Effect>
                <DropShadowEffect BlurRadius="2" ShadowDepth="2" Opacity="0.6"/>
            </Button.Effect>
        </Button>
        <ListView x:Name="OrgListView" HorizontalAlignment="Left" Height="275" VerticalAlignment="Top" Width="440" Margin="40,46,0,0" Background="#FFF3F3F3" SelectionMode="Single">
            <ListView.View>
                <GridView AllowsColumnReorder="False">
                    <GridViewColumn Header="Namn" DisplayMemberBinding="{Binding 'Name'}" Width="150"/>
                    <GridViewColumn Header="Beskrivning" DisplayMemberBinding="{Binding 'Description'}" Width="280"/>
                </GridView>
            </ListView.View>
        </ListView>
        <TextBlock x:Name="ChooseOrgText" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="40,20,0,0" Height="21" Width="440"/>
    </Grid>
</Window>
"@

# Rewrite XAML

    $inputXML = $inputXML -replace '\s{1}[\w\d_-]+="{x:Null}"',''
    $inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
    $inputXML = $inputXML -replace 'TextChanged="[\w\d-]+\w"',''
    $inputXML = $inputXML -replace 'SelectionChanged="[\w\d-]+\w"',''
    $inputXML = $inputXML -replace ' Selected="[\w\d-]+\w"',''
    $inputXML = $inputXML -replace ' Click="[\w\d-]+"',''
    $inputXML = $inputXML -replace 'Checked="CheckBox_Checked" ',''
    $inputXML = $inputXML -replace 'Checked="RadioButton_Checked" ',''

    [xml]$xaml = $inputXML
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
    }
    catch {
        Write-Warning $_.Exception
        throw
    }

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        try {
            Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop
        }
        catch {throw}
    }
#===========================================================================
#endregion VS XAML

#region Load XAML Objects In PowerShell
#===========================================================================


Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
get-variable WPF*
}

Get-FormVariables

#===========================================================================
#endregion Load XAML Objects In PowerShell


#===========================================================================
# Element Code
#===========================================================================

# WPF Object Text

    # Description
    $WPFChooseOrgText.Text = 'Choose which organisation this client will belong to after install...'
    $WPFChooseOrgText.FontSize = '12'

    #Start Installation Button
    $WPFStartInstall.Content = 'Start Installation'

# Get ListView items

    $OrgMembers=@(
        [PSCustomObject]@{Name="ORGANISATION01"; Description="Our standard organisation"; SetOrg="ORG01"}
        [PSCustomObject]@{Name="ORGANISATION02"; Description="Our branch organisation"; SetOrg="ORG02"}
        [PSCustomObject]@{Name="ORGANISATION03"; Description="Our branch organisation"; SetOrg="ORG03"}
    )

        $WPFOrgListView.ItemsSource = ($OrgMembers)

# Start installation

# Function
$WPFStartInstall.Add_Click({
   If($WPFOrgListView.SelectedItem.SetOrg -eq $null){
   $msgBoxInput = [System.Windows.MessageBox]::Show("You need to choose a organisation in order to proceed", 'Choose Organisation', 'OK')
   }
   Else{
   $TSEnvironment.Value("ORG") = $WPFOrgListView.SelectedItem.SetOrg
   Write-Host $WPFOrgListView.SelectedItem.SetOrg
       $Form.Close()
       }
})

#===========================================================================
# Shows the form
#===========================================================================

[void]$Form.ShowDialog()
