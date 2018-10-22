@echo off

set ERRORLEVEL=0

set altered=
set temp_result=tmp.txt
set result_file=res.txt
if exist %temp_result% del %temp_result%
if exist %result_file% del %result_file%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat
if not defined result_file_name set result_file_name=settings

rem echo ------------------------------------
rem echo               compatibility test
rem echo ------------------------------------

rem Delete customer
call customer_app_uninstall.bat
set /p app_uninstall=<res.txt

:_test_begin
rem Run test
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SETTINGS_RESULT> %temp_result%

rem Get result code
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar:"=% > %result_file%
set /p Result=<%result_file%

rem Store result files and save
set resultTime=%time:~0,-3%
set resultTime=%resultTime::=-%
set resultDate=%date:~4%
set resultDate=%resultDate:/=-%
..\adb pull "data/data/com.micronet.obctestingapp/files/settings.csv" "testResults\settings\%result_file_name% %resultDate% %resultTime%.csv" > nul 2>&1

set result=%Result:~28,1%
if "%result%" == "1" goto _test_pass
rem   ############## TEST STATUS ############

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo Compatibility %xprvar%
@echo Compatibility test - failed >> testResults\%result_file_name%.txt

rem Display error lines if there are any
echo. & echo    Errors:
set "xprvar="
setlocal enableDelayedExpansion
for /F "skip=2 delims=" %%i in (tmp.txt) do (
  set "xprvar=%%i"
  set altered=!xprvar:"=!
  if "!altered!" == "!xprvar!" echo       -- !xprvar!
)
endlocal
echo.

echo ** Fix errors and rerun test. Exiting...

:_exit_test
call :halt 2> nul

:halt
()
exit /b

:_test_pass
if "%app_uninstall%"=="fail" goto :_failed

set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo Compatibility %xprvar%
@echo Compatibility test - passed >> testResults\%result_file_name%.txt
goto :_end_of_file

:_failed
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo Compatibility %xprvar%
@echo Compatibility test - failed >> testResults\%result_file_name%.txt

:_end_of_file
if exist %temp_result% del %temp_result%
if exist %result_file% del %result_file%
set result=
set temp_result=

goto :eof