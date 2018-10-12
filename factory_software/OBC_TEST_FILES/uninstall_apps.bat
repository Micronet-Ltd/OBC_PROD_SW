@echo off

rem Uninstall app
..\adb uninstall com.micronet.obctestingapp > nul
..\adb uninstall me.davidvassallo.nfc > nul
call color.bat 0a "** "
echo Apps Uninstalled