@echo off

set ERRORLEVEL=0

set lowerBound=98
set upperBound=10
set rssiLowerBound=-80

set input_file=wifi_input.txt
set temp_result=tmp.txt
set success=1
set data=
set cell_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "GoodWifiRSSI" set lowerBound=%%j
)

rem echo ------------------------------------
rem echo               WiFi test            
rem echo ------------------------------------

:_test_loop
set IMEIstring=%trueIMEI:~9,6%

rem echo This is the WIFI we are looking for: TREQr_5_%IMEIstring%
netsh wlan show networks mode=bssid | find /N "TREQr_5_%IMEIstring%" > %temp_result%
set /p lineNumber=<%temp_result%
rem echo %lineNumber%
for /F "tokens=1 delims=[]" %%G in (%temp_result%) do set /A lineNumber=%%G
rem echo This is after the loop: %lineNumber%
set /A lineNumber=%lineNumber%+5
rem echo After adding: %lineNumber%
rem find /n " " finds everything and adds the line numbers to it
netsh wlan show networks mode=bssid | find /N " " | find "[%lineNumber%]" > %temp_result%
for /F "tokens=4" %%G in (%temp_result%) do set WiFiValue=%%G 
rem echo WiFiRSSI = %WiFiValue%
set /a WiFiValue=%WiFiValue:~0,-2%
rem echo Final = %WiFiValue%

if %WiFiValue% LSS %lowerBound% set cell_fail=WiFiRSSI value %WiFiValue% is less than than %lowerBound%
if %WiFiValue% LSS %lowerBound% goto _ask_if_retry

goto _test_pass

:_ask_if_retry
set "xprvar="
for /F "skip=37delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
set /p option=%xprvar%
rem echo on
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** WiFi %xprvar% %cell_fail%
@echo WiFi test - failed %cell_fail% >> testResults\%result_file_name%.txt
call update_last_result.bat system_results wifi_rssi '%WiFiValue%'
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** WiFi %xprvar% WiFi RSSI = %WiFiValue%
@echo WiFi test - passed >> testResults\%result_file_name%.txt
call update_last_result.bat system_results wifi_rssi '%WiFiValue%'
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set WiFiValue= 
set success= 
set temp_result=
set data=
set loop_count=
set IMEIstring=