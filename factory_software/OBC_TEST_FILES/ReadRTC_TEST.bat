@echo off

set currentTime_file_name=currentTime.txt
set ERRORLEVEL=0

rem echo ------------------------------------
rem echo              Read MCU RTC TEST            
rem echo ------------------------------------
rem echo ....waiting for device to boot
rem ..\adb devices 
rem ..\adb wait-for-device 

:_get_MCU_current_time

rem Get MCU RTC
..\adb shell mctl api 020b > %currentTime_file_name%
set /p MCUdate=<%currentTime_file_name%
set MCUdate="%MCUdate:~8,19%"
rem ** expected value greater then 2000-00-00 (the default value)

if %MCUdate% GEQ "2000-00-00 00:01:00" goto _test_pass


:_test_error
set ERRORLEVEL=1
echo ** RTC test - failed
@echo RTC test - failed date supposed to be greater then "2000-00-00 00:01:00" but it %MCUdate%  >> testResults\%result_file_name%.txt
goto _end_of_test


:_test_pass

echo ** RTC test - passed
@echo RTC test - passed, date is: %MCUdate% >> testResults\%result_file_name%.txt

:_end_of_test
if exist %currentTime_file_name%   del %currentTime_file_name% 

rem set MCUdate=

