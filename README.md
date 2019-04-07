# CredsLeaker v3
This script used to display a powershell credentials box asked the user for credentials.

![Credentials Box](https://raw.githubusercontent.com/Dviros/CredsLeaker/master/Screens/Box.png)

However,
That was highly noticeable. Now it's time to utilize Windows Security popup!

![Credentials Box](https://raw.githubusercontent.com/Dviros/CredsLeaker/master/Screens/New_Box.png)

As before,
The box cannot be closed (only by killing the process) will keeps checking the credentials against the DC.
When validated, it will close and leak it to a web server outside.

![Credentials Leak](https://raw.githubusercontent.com/Dviros/CredsLeaker/master/Screens/Leak.png)

# How To:
1. Start a web server.
2. Type your server IP and port in the ps1 script.
3. Execute the batch file.

# Thanks:
To all my friends that helped to craft this script (specially @deanf)



# Legal
This software is provided for educational use only (also with redteamers in mind). Don't use credsleaker without mutual consent. If you engage in any illegal activity the author does not take any responsibility for it. By using this software you agree with these terms.
