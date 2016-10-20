@echo off

set ERRORLEVEL=0
set tmp_file_name=tmp.txt



echo ------------------------------------
echo        Set RTC to  20300101        
echo ------------------------------------

echo ....waiting for device to boot
..\adb devices
..\adb wait-for-device 
rem SET Android DATE to:
..\adb shell "su 0 date -s `date +20300101.050000`"

rem Set MCU RTC (it's getting from the Android Time)
..\adb shell mctl api 020c 

goto _date_set

echo.
echo  can't set the date %status%
@echo can't set the date %status%  >> testResults\%result_file_name%.txt
goto _end_of_test

:_date_set
echo. --------- %status% -------------
echo  Set  date TO 20300101 done
@echo Set  date TO 20300101 done  >> testResults\%result_file_name%.txt


:_end_of_test
rem if exist %tmp_file_name% del %tmp_file_name%
set tmp_file_name=

