@echo off 
REM ***************************************Reset Hotspot Name****************************************
REM **This script resets the hotspot name on the device when the device is connected over ADB wired**
REM *************************************************************************************************

@echo. 
@echo -----------------------------------------------------------------------------------------------
@echo This script will reset the device's hotspot name to its default. 
@echo Please ensure that the device is connected over ADB USB 
@echo -----------------------------------------------------------------------------------------------

adb shell setprop persist.sys.iswificonfigured 0

@echo. 
@echo.
@echo Rebooting the device

adb reboot 

@echo. 
@echo Wait for the device to power up
adb wait-for-device

@echo.
@echo. 
@echo You should now be ready to run the test. 
@echo NOTE: UNPLUG YOUR USB CABLE AND FLIP THE ADB SWITCH ON THE CABLE HARNESS
 
@echo.
@echo. 

color 0F


