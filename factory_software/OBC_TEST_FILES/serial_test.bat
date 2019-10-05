@echo off

set ERRORLEVEL=0

set serial_name=serial_tmp.txt
set list_name=SerialIMEI
if exist %serial_name% del %serial_name%

rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

rem echo ------------------------------------
rem echo            SERIAL test
rem echo ------------------------------------

echo.

rem Prompt user to scan in serial number
set "xprvar="
for /F "skip=3 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0b "-> "
set /p read_in_serial=%xprvar%

:_test
rem Send broadcast to receive serial number
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL> %serial_name%

rem Parse second line of result on double quotes to get serial number whether it is 7 or 8 digits long.
set "xprvar="
for /F delims^=^"^ tokens^=2^ skip^=1 %%i in (serial_tmp.txt) do if not defined xprvar set "xprvar=%%i"

rem Final serial number from device with PM
set pm_serial=PM%xprvar%

rem If serial number scanned is the same as the one in the device then goto pass
if "%pm_serial%" == "%read_in_serial%" goto _test_pass

:_test_fail
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=4 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo %xprvar%
endlocal
@echo Serial test - failed expected %pm_serial% got %read_in_serial% >> testResults\%result_file_name%.txt
goto _end_of_file

rem   ############## TEST STATUS ############
:_test_pass
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=5 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo %xprvar%
endlocal
@echo Serial test - passed %pm_serial% >> testResults\%result_file_name%.txt

:_end_of_file
if exist %serial_name% del %serial_name%
set Result=
set read_in_serial=
set pm_serial=
