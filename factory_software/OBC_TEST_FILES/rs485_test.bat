@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set loop_count=0
set rs485_fail=
if exist %temp_result% del %temp_result%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo               RS485 test            
rem echo ------------------------------------

rem For testing, RS485 is connected to RS485 on the tester device.
rem Result code:
rem 		 0 = app isn't installed or started, 
rem 		 1 = success, 
rem 		 2 = fail and result data will contain which ones failed,
rem In the case that it fails to send or receive an "F" will be placed in result data instead of "P"
rem Example: A success result's data will look like "P"
rem The "P" is for tx out of RS485 and a successful response rx in RS485
rem So if there is a failure then the resulting data would look like "F":
rem The "F" means tx out of RS485 and not a succesful response rx in RS485

rem Enable RS485
..\adb shell "mctl api 0213041b01" > nul

:_test_loop
rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_RS485_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

rem Result data should only be one character long
set data=%Result:~37,1%

if "%Result:~28,1%"=="%success%" goto _test_pass

set Result=
goto _ask_if_retry

:_ask_if_retry
set "xprvar="
for /F "skip=14 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo  ** RS485 %xprvar%
if "%data:~0,1%" == "F" (
	set rs485_fail="RS485 failed: did not send/receive characters back correctly",
)
@echo RS485 test - failed %rs485_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** RS485 %xprvar%
@echo RS485 test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
rem Disable RS485
..\adb shell "mctl api 0213041b00" > nul
rem Reconfigure port tty flags. This is done to make sure the com test works after this.
..\adb shell "busybox stty -F /dev/ttyUSB1 500:5:cbd:8a3b:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0" > nul
..\adb shell "busybox stty -F /dev/ttyUSB1 9600" > nul
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set loop_count=
set rs485_fail=