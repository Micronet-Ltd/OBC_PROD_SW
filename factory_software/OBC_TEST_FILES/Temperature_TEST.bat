@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
if exist %file_name% del %file_name%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

rem echo ------------------------------------
rem echo                Temperature Test            
rem echo ------------------------------------


:_test_get_temperature

..\adb shell mctl api 02040A > %file_name%

set /p temperature=<%file_name%
set temperature=%temperature:~25,4%
rem @echo %temperature%
rem echo %temperature%
SET /A temperature=(%temperature% - 500)/ 10
rem @echo %temperature%
rem pause
if %temperature% LSS 20 goto _temperature_value_error
if %temperature% GTR 50 goto _temperature_value_error
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Temperature %xprvar% 
@echo Temperature test - passed  temperature is: %temperature%  >> testResults\%result_file_name%.txt
goto _end_of_file

:_temperature_value_error
set ERRORLEVEL=1
rem echo.
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Temperature %xprvar% Expected temperature 20-50c got %temperature%
@echo Temperature  test - failed Expected temperature 20-50c got %temperature%  >> testResults\%result_file_name%.txt


:_end_of_file
if exist %file_name% del %file_name%

set file_name= 
set temperature= 