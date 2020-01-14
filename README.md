# CredsLeaker v4.x

This script used to display a powershell credentials box asked the user for credentials.
However,
That was highly noticeable. Now it's time to utilize Windows Security popup!

![Credentials Box](https://raw.githubusercontent.com/Dviros/CredsLeaker/master/Screens/New_Box.png)

# Features
- AD domain authentication validation.
- Tested on Windows 10 (1809, 1903, 1909) with Powershell version 5.1. Needs to be tested on 7\8\8.1\ Servers and different powershell versions.
- Can be modified (title, message etc.).
- Added WORKGROUP support (validation is done against the local SAM).
- Added parameters support. Now you can customize the messages, captions, IP's and ports from the command line.
# Feature Additions in this fork
- Optimized for HID style scenerios
- Export to USB/CSV
- POST array and php handler for easy http customization
- Pipeline and dynamic switching between USB and HTTP export
- Timed delay for delayed deployment
- Delayed delivery of leaked credentials if delivery option unaccessible
- Config file to override default params pulled from USB first, Web second (if no USB).  Pipeline option to override config file.
- Config file fully editable via web form (config.php) so script can be run completely on the fly with no need to alter command line params.

The box cannot be closed (only by killing the process) and will keep on checking the credentials against the DC. If credentials fail at the DC, then they are checked against local SAM so that local accounts are leaked even if the machine is a domain member.  When validated, it will close and process via chosen method.

![Credentials Leak](https://raw.githubusercontent.com/Dviros/CredsLeaker/master/Screens/Leak.png)

# How To:

1. Start a web server and upload cl_reader.php, config.php, config.cl to desired path

2. Fill out parameter defaults in CredsLeaker.ps1
3. Edit Pipeline parameters in run.bat to desired scenerio
4. Execute run.bat file.

# Thanks:
To Dviros for a great script that I have learned a ton from!
To all my friends that helped to craft this script (specially @deanf)

# Legal
This software is provided for educational use only (also with redteamers in mind). Don't use credsleaker without mutual consent. If you engage in any illegal activity the author does not take any responsibility for it. By using this software you agree with these terms.
