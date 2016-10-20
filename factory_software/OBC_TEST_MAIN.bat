@echo off
set test_script_version=1.2.3
cls
echo ---------------------------------------------------
echo  starting test, test script version is : %test_script_version%
rem echo         Waiting for Device            
echo ---------------------------------------------------

cd OBC_TEST_FILES
set OBC_TEST_STSATUS=PASS

rem echo %OBC_TESTER_WLAN_HOTSPOT%
call WLAN_profile.bat %1
IF %ERRORLEVEL% NEQ 0 goto _end_of_tests
call WLAN_CONNECT.bat %1
call adb_CONNECT.bat %1
rem echo wait for devices 
rem ..\adb devices
rem ..\adb wait-for-device 
rem ..\adb devices

rem ------------  create a status file -----------------
set result_file_name=tmp.txt
..\adb shell getprop ro.serialno > %result_file_name%
set /p deviceSN=<%result_file_name%
set mydate=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%
rem echo device Serial Number: %deviceSN%, Date:  %mydate%
set result_file_name=%deviceSN%
rem _%mydate%
@echo Device SN : %deviceSN%  > testResults\%result_file_name%.txt
@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
set mydate=
set deviceSN=
rem end create status file ----------

call LED_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

rem echo installing files ....
call install_files_test.bat
rem timeout /T 5 /NOBREAK

call SWC_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call J1708_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call sd-card_test.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call NFC_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call VERSION_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call HELP_KEY_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call audio_test.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call Temperature_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call ReadRTC_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call CANBus.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call Accelerometer.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call GPIO_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

call SUPERCAP_TEST.bat
if %ERRORLEVEL% == 1 set OBC_TEST_STSATUS=Fail

if /I not %OBC_TEST_STSATUS%==PASS goto _test_failed
echo **************************************
echo ***** Entire OBC test passed !!! *****
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ***** Entire OBC test passed !!! ***** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
goto _end_of_tests

:_test_failed
echo **************************************
echo ***** Entire OBC test failed !!! *****
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ***** Entire OBC test failed !!! ***** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
:_end_of_tests
set test_script_version=
set OBC_TEST_STSATUS=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_00%1>nul
cd ..