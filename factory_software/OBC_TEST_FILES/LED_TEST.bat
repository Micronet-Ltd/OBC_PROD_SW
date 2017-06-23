@echo off

set ERRORLEVEL=0

rem echo ------------------------------------
rem echo                LED TEST            
rem echo ------------------------------------
..\adb shell mctl api 0206000FFFFFFF>nul
..\adb shell mctl api 0206010FFFFFFF>nul
..\adb shell mctl api 0206020FFFFFFF>nul

set choice=
:_ask_if_on
echo.&set /p choice=Do you see the 3 LEDs in white and same brightness ?[Y/N] ?
if /I "%choice%"=="Y" goto _test_pass
if /I "%choice%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_on

rem   ############## TEST STATUS ############
:_test_fail
set ERRORLEVEL=1
echo ** LED test - failed
@echo LED test - failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_test_pass
echo ** LED test- passed
@echo LED test- passed  >> testResults\%result_file_name%.txt

:_end_of_file
..\adb shell mctl api 02060000FF0000>nul
..\adb shell mctl api 02060100FF0000>nul
..\adb shell mctl api 0206020F00FF00>nul
set choice=	
