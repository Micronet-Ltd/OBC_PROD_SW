@echo off

set ERRORLEVEL=0

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo                LED UD TEST            
rem echo ------------------------------------

rem Change the left LED to white
..\adb shell mctl api 0206020FFFFFFF>nul

:_ask_if_on
set choice=
set "xprvar="
for /F "skip=40 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.
call color.bat 0b "-> "
set /p choice=%xprvar%
if /I "%choice%"=="Y" goto _test_pass
if /I "%choice%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_on

rem   ############## TEST STATUS ############
:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=7 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo %xprvar%
@echo LED test - failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_test_pass
set "xprvar="
for /F "skip=8 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo %xprvar%
@echo LED test- passed  >> testResults\%result_file_name%.txt

:_end_of_file
..\adb shell mctl api 0206020F00FF00>nul
set choice=	
