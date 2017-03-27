@echo off

set ERRORLEVEL=0

set serial_name=serial_tmp.txt
set list_name=SerialIMEI
if exist %serial_name% del %serial_name%

rem echo ------------------------------------
rem echo                SERIAL test            
rem echo ------------------------------------

rem Prompt user to scan in serial number
set /p read_in_serial=Scan Serial Number:

:_test
rem Send broadcast to receive serial number
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL> %serial_name%

rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (serial_tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %serial_name%

rem Parse serial number
set /p Result=<%serial_name%

rem Final serial number from device with PM
set pm_serial=PM%Result:~58,8%

rem If serial number scanned is the same as the one in the device then goto pass
if "%pm_serial%" == "%read_in_serial%" goto _test_pass


set ERRORLEVEL=1
echo  ** Serial test - failed expected %pm_serial% got %read_in_serial%
@echo Serial test - failed expected %pm_serial% got %read_in_serial% >> testResults\%result_file_name%.txt
goto _end_of_file


rem   ############## TEST STATUS ############
:_test_pass
echo ** Serial test - passed %pm_serial%
@echo Serial test - passed %pm_serial% >> testResults\%result_file_name%.txt

:_end_of_file
if exist %serial_name% del %serial_name%
set Result= 
set read_in_serial= 
set pm_serial=