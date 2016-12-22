@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                IMEI test            
rem echo ------------------------------------

rem   ############## display message to the tester ############

rem echo. 
rem echo ***************************************
rem echo scan the IMEI number 
set /p imei=Scan IMEI: 
rem echo %imei%

:_test
Rem get IMEI to a file 
..\adb shell am broadcast -a com.Micronet.IMEIviaADB.GET_IMEI> %file_name%
REM get the secod line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %file_name%

set /p Result=<%file_name%
rem echo %Result:~37,15% 



rem Read IMEI from the device

set /p Result=<%file_name%
if "%Result:~37,15%" == "%imei%" goto _uninstall_apk


set ERRORLEVEL=1
echo  ** IMEI test - failed expeted %Result:~37,15% got %imei%
@echo IMEI test - failed expeted %Result:~37,15% got %imei% >> testResults\%result_file_name%.txt


:_uninstall_apk
rem uninstall the apk
..\adb uninstall com.Micronet.IMEIviaADB > nul
if %ERRORLEVEL% == 1 goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
rem echo.
echo ** IMEI test - passed %imei%
@echo IMEI test - passed %imei% >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %file_name% del %file_name%
set Result= 
set imei= 