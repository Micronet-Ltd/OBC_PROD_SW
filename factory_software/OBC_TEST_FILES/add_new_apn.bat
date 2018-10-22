@echo off
rem Update APN

if exist tmp.txt del tmp.txt

set options_file=input\test_options.dat

rem initialize to blank
set "apn="
set "name="
set "mcc="
set "mnc="
set "user="
set "password="

rem get the package name from input file
for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "apn" set apn=%%j
 if /i "%%i" == "name" set name=%%j
 if /i "%%i" == "mcc" set mcc=%%j
 if /i "%%i" == "mnc" set mnc=%%j
 if /i "%%i" == "user" set user=%%j
 if /i "%%i" == "password" set password=%%j
)

echo.

rem Update current apn
..\adb shell am startservice -a com.inthinc.SET_APN -e apn %apn% -e mcc %mcc% -e mnc %mnc% -e name '%name%' > nul
call color.bat 0a "** "
echo Updated current apn to: name-'%name%' apn-%apn% mcc-%mcc% mnc-%mnc%

rem Updated username and password if specified in the input file
if defined user ..\adb shell "sqlite3 /data/data/com.android.providers.telephony/databases/telephony.db \"update carriers set user='%user%', password='%password%', authtype=2 where mcc='%mcc%' and mnc='%mnc%';\""
if defined user echo Updated current apn: user-%user% password-%password%

echo To change the APN settings, change the input values in "input\test_options.dat" under APN and restart the test.