@echo off
rem Run this command to toggle the Buzzer and LED
:_start_test
..\adb shell mctl api 0x1c>nul
timeout /t 1 > nul 2>&1
..\adb shell mctl api 0x1c>nul

:_ask_if_on
echo.
set choice=
set "xprvar="
for /F "skip=43 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0b "-> "
set /p choice=%xprvar%
if /I "%choice%"=="Y" goto _test_pass
if /I "%choice%"=="N" goto _ask_if_retry
echo Invalid option
goto _ask_if_on

:_ask_if_retry
set "xprvar="
for /F "skip=46 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _start_test
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

rem   ############## TEST STATUS ############
:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=44 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo %xprvar%
@echo Buzzer_LED test - failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_test_pass
set "xprvar="
for /F "skip=45 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo %xprvar%
@echo Buzzer_LED test- passed  >> testResults\%result_file_name%.txt

:_end_of_file

set choice=
