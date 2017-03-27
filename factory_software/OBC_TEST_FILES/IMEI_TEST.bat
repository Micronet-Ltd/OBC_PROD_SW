@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
set serial_name=serial_tmp.txt
set list_name=SerialIMEI
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%

rem echo ------------------------------------
rem echo                IMEI test            
rem echo ------------------------------------

set /p imei=Scan IMEI: 

:_test
rem Get IMEI to a file 
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_IMEI> %file_name%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %file_name%

set /p Result=<%file_name%

rem If IMEI scanned in is same as IMEI on device then goto pass
if "%Result:~37,15%" == "%imei%" goto _test_pass

set ERRORLEVEL=1
echo  ** IMEI test - failed expected %Result:~37,15% got %imei%
@echo IMEI test - failed expected %Result:~37,15% got %imei% >> testResults\%result_file_name%.txt
if %ERRORLEVEL% == 1 goto :_write_serial_imei

rem   ############## TEST STATUS ############
:_test_pass
echo ** IMEI test - passed %imei%
@echo IMEI test - passed %imei% >> testResults\%result_file_name%.txt

:_write_serial_imei
rem write SerialNumber and IMEI to SerialIMEI.csv
rem get uppercase serial
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL> %serial_name%

REM get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (serial_tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %serial_name%

set /p Result=<%serial_name%

rem Parse serial number
set pm_serial=%Result:~58,8%

rem Write Serial and IMEI to SerialIMEI.csv
@echo %pm_serial%,%imei% >> testResults\%list_name%.csv
goto _end_of_file


:_end_of_file
rem Uninstall app
..\adb uninstall com.micronet.obctestingapp > nul
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%
set Result= 
set imei= 
set pm_serial=