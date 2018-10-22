@echo off

set currentTime_file_name=currentTime.txt
set ERRORLEVEL=0

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo              Read RTC TEST            
rem echo ------------------------------------

:_get_MCU_current_time
rem Get MCU RTC
..\adb shell mctl api 020b > %currentTime_file_name%
set /p MCUdate=<%currentTime_file_name%
set MCUdate="%MCUdate:~8,19%"
rem ** expected value greater then 2000-00-00 (the default value)
if %MCUdate% GEQ "2000-00-00 00:01:00" goto _test_pass

:_test_error
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo RTC %xprvar%
@echo RTC test - failed date supposed to be greater then "2000-00-00 00:01:00" but it %MCUdate%  >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo RTC %xprvar%
@echo RTC test - passed, date is: %MCUdate% >> testResults\%result_file_name%.txt

:_end_of_test
if exist %currentTime_file_name%   del %currentTime_file_name% 
