@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set settings_file=settings.csv
if exist %temp_result% del %temp_result%
if exist %settings_file% del %settings_file%


rem echo ------------------------------------
rem echo               Settings test
rem echo ------------------------------------

:_test_begin

rem Run test
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SETTINGS_RESULT> %temp_result%
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

set result=%Result:~28,1%

rem Batch might parse ,,, as something odd
..\adb pull "data/data/com.micronet.obctestingapp/files/settings.csv" "settings.csv"
for /F "tokens=1,2,3,4,5 delims=," %%G in (settings.csv) do echo %%G: %%J

rem TODO add in error checking
pause
goto :_end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set result=
set temp_result=

goto :eof
