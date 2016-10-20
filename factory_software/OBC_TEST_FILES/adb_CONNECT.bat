@echo off

set ERRORLEVEL=0

rem echo ------------------------------------
rem echo         adb connect to 192.168.43.1
rem echo ------------------------------------

set network_file_name=wlan.txt
set OBC_TESTER_WLAN_HOTSPOT_HEADER=TREQr_5_00
set OBC_TESTER_WLAN_HOTSPOT_NUNER=%1
set OBC_TESTER_WLAN_HOTSPOT=%OBC_TESTER_WLAN_HOTSPOT_HEADER%%OBC_TESTER_WLAN_HOTSPOT_NUNER%

rem echo OBC_TESTER_WLAN_HOTSPOT%


if exist %network_file_name% del %network_file_name%
rem echo waiting for WLAN (20 attempts)
set /a loop_cnt = 0

:_WLAN_LOOP
echo | set /p=.
set /a loop_cnt = %loop_cnt% + 1
..\adb connect 192.168.43.1>%network_file_name%
set /p OBC_TESTER_WLAN_CON=<%network_file_name%

rem read the first letter of the File which its context can be either:
rem Connection request was completed successfully.       OR
rem There is no profile assigned to the specified interface.
rem if the 1st letter is 'C', connection succeded or 'a' already connected, else faild

if %OBC_TESTER_WLAN_CON:~0,1% == c goto _WALN_test_pass
if %OBC_TESTER_WLAN_CON:~0,1% == a goto _WALN_test_pass
if %loop_cnt% LSS 20 goto _WLAN_LOOP

rem   ############## TEST STATUS ############
set ERRORLEVEL=1
echo adb connect faild  %OBC_TESTER_WLAN_CON% 
goto _end_of_test

:_WALN_test_pass
echo adb Connected Passed

:_end_of_test
if exist %network_file_name% del %network_file_name%
set loop_cnt=
set network_file_name=
set OBC_TESTER_WLAN_HOTSPOT_HEADER=
set OBC_TESTER_WLAN_HOTSPOT_NUNER=
set OBC_TESTER_WLAN_HOTSPOT=
set OBC_TESTER_WLAN_CON=