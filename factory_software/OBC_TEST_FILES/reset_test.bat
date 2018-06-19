@echo off

set ERRORLEVEL=0

set time_file_name=time_before_reset.txt
set status_file_name=device_status.txt

echo ------------------------------------
echo              RESET KEY            
echo ------------------------------------

rem SET DATE
echo SET RTC time to:
..\adb shell "su 0 date -s `date +20300101.050000`"

echo | set /p=PRESS RESET KEY 

:_get_time_before_reset
if exist %time_file_name% del %time_file_name%
..\adb shell date +%%s > %time_file_name%

set /a loop_cnt = 0
rem read the first letter of the File which its context can be either:
rem Connection request was completed successfully.       OR
rem There is no profile assigned to the specified interface.
rem if the 1st letter is 'C', connection succeded, else faild
rem if the 1st letter is not C it means that reset done 
:_loop
echo | set /p=.
if exist %status_file_name% del %status_file_name%
set /a loop_cnt = %loop_cnt% + 1
netsh WLAN connect %OBC_TESTER_WLAN_HOTSPOT%>%status_file_name%
set /p device_status=<%status_file_name%
if %OBC_TESTER_WLAN_CON:~0,1% NEQ C goto _device_reset
if %loop_cnt% LSS 200 goto _loop

rem   ############## TEST STATUS ############
rem At this stage RESET was not pressed and time out
echo.
set ERRORLEVEL=1
if exist %time_file_name% del %time_file_name%
echo *** ERROR !!! - RESET button not pressed ***
@echo Reset KEY TEST - faile  >> testResults\%result_file_name%.txt

goto _end_of_test

:_device_reset
echo.
echo RELEASE RESET KEY
echo RESET TEST - PASS 
@echo Reset KEY TEST - PASS  >> testResults\%result_file_name%.txt


:_end_of_test
if exist %status_file_name% del %status_file_name%
rem  moved to main function  --- netsh wlan connect TREQr_5_003252
set time_file_name=
set status_file_name=
