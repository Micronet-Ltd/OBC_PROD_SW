@echo off
rem Update APN

if exist tmp.txt del tmp.txt
set results=

rem Check if apn already exists
..\adb shell "content query --uri content://telephony/carriers --where ""name='testingAPN'""" > tmp.txt
set /p results=<tmp.txt > nul 2>&1

rem echo %results%

if not "%results:~0,1%"=="N" goto _already_contains

rem If it doesn't exist then put it in 
..\adb shell content insert --uri content://telephony/carriers --bind name:s:"testingAPN" --bind numeric:s:"310410" --bind type:s:"default,sulp" --bind mcc:i:310 --bind mnc:s:410 --bind apn:s:broadband

rem Update the preferred apn
..\adb shell content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:1502

rem The _id of the newly inserted apn should be 1502

echo APN updated.
echo.
if exist tmp.txt del tmp.txt
set results=

rem Reselect the selected apn
..\adb shell am start -a android.settings.SETTINGS >nul
timeout 2 >nul
..\adb shell input tap 200 500
timeout 1 >nul
..\adb shell input tap 100 650
timeout 1 >nul
..\adb shell input tap 200 250
timeout 1 >nul
..\adb shell input tap 425 150
timeout 1 >nul
..\adb shell input tap 425 235
timeout 2 >nul

goto :eof

:_already_contains
echo Already contains the APN.
echo.

if exist tmp.txt del tmp.txt
set results=

rem Reselect the selected apn
..\adb shell am start -a android.settings.SETTINGS >nul
timeout 2 >nul
..\adb shell input tap 200 500
timeout 1 >nul
..\adb shell input tap 100 650
timeout 1 >nul
..\adb shell input tap 200 250
timeout 1 >nul
..\adb shell input tap 425 150
timeout 1 >nul
..\adb shell input tap 425 235
timeout 2 >nul
