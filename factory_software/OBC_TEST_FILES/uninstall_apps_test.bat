@echo off

rem Uninstall app
..\adb uninstall com.micronet.obctestingapp > nul
..\adb uninstall me.davidvassallo.nfc > nul
echo ** Apps Uninstalled