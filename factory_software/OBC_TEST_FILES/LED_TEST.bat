@echo off

set ERRORLEVEL=0

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

rem echo ------------------------------------
rem echo                LED TEST            
rem echo ------------------------------------
..\adb shell mctl api 0206000FFFFFFF>nul
..\adb shell mctl api 0206010FFFFFFF>nul
..\adb shell mctl api 0206020FFFFFFF>nul

:_ask_if_on
set choice=
set "xprvar="
for /F "skip=6 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I "%choice%"=="Y" goto _test_pass
if /I "%choice%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_on

rem   ############## TEST STATUS ############
:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=7 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
@echo LED test - failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_test_pass
set "xprvar="
for /F "skip=8 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
@echo LED test- passed  >> testResults\%result_file_name%.txt

:_end_of_file
..\adb shell mctl api 02060000FF0000>nul
..\adb shell mctl api 02060100FF0000>nul
..\adb shell mctl api 0206020F00FF00>nul
set choice=	
