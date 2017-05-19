@echo off

set ERRORLEVEL=0

rem echo ------------------------------------
rem echo         adb connect to 192.168.43.1
rem echo ------------------------------------

set network_file_name=wlan.txt
set OBC_TESTER_WLAN_HOTSPOT_HEADER=TREQr_5_00
set OBC_TESTER_WLAN_HOTSPOT_NUNER=%1
set OBC_TESTER_WLAN_HOTSPOT=%OBC_TESTER_WLAN_HOTSPOT_HEADER%%OBC_TESTER_WLAN_HOTSPOT_NUNER%

set loop_count=0
set temp_result=tmp.txt
set root_result=
set root_string=uid=0(root)
if exist %temp_result% del %temp_result%


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

if %OBC_TESTER_WLAN_CON:~0,1% == c goto _root_loop
if %OBC_TESTER_WLAN_CON:~0,1% == a goto _root_loop
if %loop_cnt% LSS 20 goto _WLAN_LOOP

rem   ############## TEST STATUS ############
:_WLAN_test_fail
set ERRORLEVEL=1
echo ** adb connect failed %OBC_TESTER_WLAN_CON%
goto _end_of_test

:_root_loop
rem Need to make sure it is actually getting root because sometimes it is failing
set loop_count=0

:_get_root
..\adb root > nul 2>&1
..\adb connect 192.168.43.1 > nul 2>&1
timeout /T 1 /NOBREAK > nul
..\adb shell id> %temp_result%
set /p root_result=<%temp_result%

rem check id to make sure adb is root
if "%root_result:~0,11%" == "%root_string%" goto _WLAN_test_pass

set /a loop_count=%loop_count%+1
set root_result=

if %loop_count% GTR 2 goto _WLAN_test_fail

timeout /T 1 /NOBREAK > nul

goto _get_root

:_WLAN_test_pass
echo adb Connected Passed

:_end_of_test
if exist %network_file_name% del %network_file_name%
if exist %temp_result% del %temp_result%
set loop_cnt=
set network_file_name=
set OBC_TESTER_WLAN_HOTSPOT_HEADER=
set OBC_TESTER_WLAN_HOTSPOT_NUNER=
set OBC_TESTER_WLAN_HOTSPOT=
set OBC_TESTER_WLAN_CON=
set loop_count=
set root_result=
set root_string=
set temp_result=