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
set state=
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
rem if the 1st letter is 'c', connection succeded or 'a' already connected, else faild
rem echo %OBC_TESTER_WLAN_CON%

if %OBC_TESTER_WLAN_CON:~0,1% == c goto _root_loop
if %OBC_TESTER_WLAN_CON:~0,1% == a goto _root_loop
if %loop_cnt% LSS 20 goto _WLAN_LOOP
rem If loop_cnt greater than 20 than fail test
goto _WLAN_test_fail

:_root_loop
rem Need to make sure it is actually getting root because sometimes it is failing
set loop_count=0

:_get_root
..\adb root > nul 2>&1
..\adb connect 192.168.43.1 > %temp_result%
set /p root_result=<%temp_result%
rem echo %root_result%
rem checking this below will ensure that the device is connected before trying to run the shell command
if %root_result:~0,1% == c goto _check_if_root
if %root_result:~0,1% == a goto _check_if_root

set /a loop_count=%loop_count%+1
set root_result=

if %loop_count% GTR 8 goto _WLAN_test_fail

timeout /T 1 /NOBREAK > nul

goto _get_root

:_check_if_root
if exist %temp_result% del %temp_result%
set root_result=

rem check adb state. Had problem where connection passed but device was offline
..\adb get-state > %temp_result%
set /p state=<%temp_result%
rem echo %state%
set correct_state=device
if not "%state%" == "%correct_state%" goto _retry

if exist %temp_result% del %temp_result%
..\adb shell id > %temp_result%
set /p root_result=<%temp_result%
rem echo %root_result%

rem check id to make sure adb is root
if "%root_result:~0,11%" == "%root_string%" goto _WLAN_test_pass

:_retry

set /a loop_count=%loop_count%+1
set root_result=

if %loop_count% GTR 8 goto _WLAN_test_fail_state

timeout /T 1 /NOBREAK > nul

goto _get_root

rem   ############## TEST STATUS ############
:_WLAN_test_fail
set ERRORLEVEL=1
echo ** adb Connect failed %OBC_TESTER_WLAN_CON%
goto _end_of_test

:_WLAN_test_fail_state
set ERRORLEVEL=1
echo ** adb Connect failed - error with root or state. device state: %state%
goto _end_of_test

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
set state=