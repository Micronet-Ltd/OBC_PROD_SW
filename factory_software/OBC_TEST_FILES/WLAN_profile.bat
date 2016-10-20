@echo off
set IMEIstring=%1
set IMEI=%1
set ERRORLEVEL=

rem echo ------------------------------------
rem echo         WLAN profile
rem echo ------------------------------------
echo  wait for TREQr_5_00%IMEIstring% ...
:_refresh_wireless_networks
rem ------------ Main -----------------
call :_check_Permissions
IF %ERRORLEVEL% NEQ 0 goto _end_of_test
set wait_seconds=2
call :_refresh_networks
call :_wait for_wifi
set myhex=
call :toHex
call :createProfile
goto _WALN_addProfle_pass
rem ----------- End Main

rem start wait for Wi-Fi------------------------------------------------------
:_wait for_wifi
set found="Not Found"
rem checking if the PC sees the device hotspot 

netsh wlan show networks > networks.txt
findstr /m TREQr_5_00%IMEIstring% networks.txt > tmp.txt
rem findstr /m "QA-Test" networks.txt > tmp.txt
set /p found= < tmp.txt
rem if the wifi network exist the the findster will return the file name
rem echo  found = %found%
if %found%==networks.txt EXIT /B
rem echo Please check if the device is on ...
timeout /T %wait_seconds% /NOBREAK > nul
echo | set /p=.
if %wait_seconds% LSS 15 set /a wait_seconds = %wait_seconds% * 2
goto _wait for_wifi
rem End wait for Wi-Fi ---------------------------------------------------------


:_refresh_networks
rem  start refresh (re-scan) wireless networks -----------------------------------
rem Force refresh (re-scan) wireless networks 
rem ***** This operation needs administrator privilege. ****
rem the commnad to get network name is: netsh wlan show interfaces
call :_get_NetworkName
netsh interface set interface name=%NetworkName% admin=disabled >nul 2>&1
netsh interface set interface name=%NetworkName% admin=enabled >nul 2>&1
set NetworkName=
EXIT /B
rem  End refresh (re-scan) wireless networks ----------------------------------------------------------------


rem Start checking Administrative permissions----------------------------------------------------------- 
:_check_Permissions
    net session >nul 2>&1
    if %errorLevel% NEQ 0 (
	echo *********************************************
	echo **** Administrative permissions required ****
	echo *********************************************
     )
EXIT /B
rem End checking Administrative permissions-----------------------------------------------------------


rem  start to Hex--------------------------------------------------------------------------------------
:toHex
if defined IMEI (
      
	set myhex=%myhex%3%IMEI:~0,1%
	set IMEI=%IMEI:~1%
	goto toHex
)

EXIT /B
rem End to Hex ----------------------------------------------------------------------------------------

rem Start get Network name -----------------------------------------------------------------------------
:_get_NetworkName
ver | find "5.1" > nul
 
if errorlevel = 1 goto next0
if errorlevel = 0 goto xp
 
:next0
ver | find "6.0" > nul
if errorlevel = 1 goto next
if errorlevel = 0 goto win vista
 
:next
ver | find "6.1"
if errorlevel = 1 goto next1
if errorlevel = 0 goto win7
 
:next1
ver | find "6.2" > nul
if errorlevel = 1 goto next2
if errorlevel = 0 goto win8
 
:next2
ver | find "6.3" > nul
if errorlevel = 1 goto next3
if errorlevel = 0 goto win8.1
 
:next3
ver | find "6.3" > nul
if errorlevel = 1 goto next4
if errorlevel = 0 goto win8.1
 
:next4
ver | find "10.0" > nul
if errorlevel = 1 goto other
if errorlevel = 0 goto win10
 
:xp
echo OS = XP
echo write down the name and call Micronet 
netsh wlan show interfaces
pause 
EXIT /B
 
:win vista
rem echo  OS = Vista
set NetworkName="Wireless Network Connection"
EXIT /B
  
:win7
rem echo  OS = Window 7
set NetworkName="Wireless Network Connection"
EXIT /B
 
:win8
rem echo OS = Window 8
set NetworkName="Wi-FI"
EXIT /B
 
:win8.1
rem echo OS = Window 8.1
set NetworkName="Wi-FI"
EXIT /B
 
:win10
rem echo OS = Window 10
set NetworkName="Wi-FI"
EXIT /B
 
:other
echo Early Win
echo write down the name and call Micronet 
netsh wlan show interfaces
pause 
EXIT /B
rem end get NetWork Name


rem Start creating the profile -------------------------------------------------------------------------
:createProfile
rem create a profile 
@echo ^<?xml version="1.0"?^> > Wi-Fi-TREQr_5.xml
@echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^> >> Wi-Fi-TREQr_5.xml
@echo 	^<name^>TREQr_5_00%IMEIstring%^</name^> >> Wi-Fi-TREQr_5.xml
@echo 	^<SSIDConfig^>  >> Wi-Fi-TREQr_5.xml
@echo 		^<SSID^>  >> Wi-Fi-TREQr_5.xml
@echo 			^<hex^>54524551725F355F3030%myhex%^</hex^>  >> Wi-Fi-TREQr_5.xml
@echo 			^<name^>TREQr_5_00%IMEIstring%^</name^> >> Wi-Fi-TREQr_5.xml
@echo 		^</SSID^> >> Wi-Fi-TREQr_5.xml
@echo 	^</SSIDConfig^> >> Wi-Fi-TREQr_5.xml
@echo 	^<connectionType^>ESS^</connectionType^> >> Wi-Fi-TREQr_5.xml
@echo 	^<connectionMode^>auto^</connectionMode^> >> Wi-Fi-TREQr_5.xml
@echo 	^<MSM^> >> Wi-Fi-TREQr_5.xml
@echo 		^<security^> >> Wi-Fi-TREQr_5.xml
@echo 			^<authEncryption^> >> Wi-Fi-TREQr_5.xml
@echo 				^<authentication^>WPA2PSK^</authentication^> >> Wi-Fi-TREQr_5.xml
@echo 				^<encryption^>AES^</encryption^> >> Wi-Fi-TREQr_5.xml
@echo 				^<useOneX^>false^</useOneX^> >> Wi-Fi-TREQr_5.xml
@echo 			^</authEncryption^> >> Wi-Fi-TREQr_5.xml
@echo 			^<sharedKey^> >> Wi-Fi-TREQr_5.xml
@echo 				^<keyType^>passPhrase^</keyType^> >> Wi-Fi-TREQr_5.xml
@echo 				^<protected^>false^</protected^> >> Wi-Fi-TREQr_5.xml
@echo 				^<keyMaterial^>2000%IMEIstring%^</keyMaterial^> >> Wi-Fi-TREQr_5.xml
@echo 			^</sharedKey^> >> Wi-Fi-TREQr_5.xml
@echo 		^</security^> >> Wi-Fi-TREQr_5.xml
@echo 	^</MSM^> >> Wi-Fi-TREQr_5.xml
@echo 	^<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3"^> >> Wi-Fi-TREQr_5.xml
@echo 		^<enableRandomization^>false^</enableRandomization^> >> Wi-Fi-TREQr_5.xml
@echo 	^</MacRandomization^> >> Wi-Fi-TREQr_5.xml
@echo ^</WLANProfile^> >> Wi-Fi-TREQr_5.xml

Netsh WLAN add profile filename="Wi-Fi-TREQr_5.xml" >nul 2>&1
EXIT /B
rem End creating the profile -------------------------------------------------------------------------
:_WALN_addProfle_pass
echo WALN profile- Passed 

:_end_of_test
set myhex=
set found=
if exist networks.txt del networks.txt
if exist tmp.txt del tmp.txt