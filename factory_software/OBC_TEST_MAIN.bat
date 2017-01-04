@echo off
set test_script_version=1.2.10
cls
echo ---------------------------------------------------
echo  starting test, test script version is : %test_script_version%
rem echo         Waiting for Device            
echo ---------------------------------------------------

cd OBC_TEST_FILES
set OBC_TEST_STSATUS=PASS

rem echo %OBC_TESTER_WLAN_HOTSPOT%
rem call WLAN_profile.bat %1
rem IF %ERRORLEVEL% NEQ 0 goto _end_of_tests
rem call WLAN_CONNECT.bat %1
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
@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt

rem add new line to summary file
echo: >>testResults\summary.csv

<nul set /p ".=%mydate%," >> testResults\summary.csv
<nul set /p ".=%deviceSN%," >> testResults\summary.csv

set mydate=
set deviceSN=
rem end create status file ----------

rem get imei
start python GetOBCValues1.py

rem get IMEI from the user
set deviceIMEI=error
set /p scannedIMEI=Scan IMEI: 
set /p deviceIMEI=<IMEIrsult.txt
if %scannedIMEI%==%deviceIMEI% (
	echo ** IMEI test - passed
	@echo IMEI test - passed.  >> testResults\%result_file_name%.txt
	) else (
	echo ** IMEI test - failed. Device IMEI = %deviceIMEI%, Lable IMEI = %scannedIMEI%
	@echo IMEI test - failed. Device IMEI = %deviceIMEI%, Lable IMEI = %scannedIMEI%  >> testResults\%result_file_name%.txt
	)
if exist IMEIrsult.txt del IMEIrsult.txt

call LED_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

rem echo installing files ....
call install_files_test.bat
rem timeout /T 5 /NOBREAK

call sd-card_test.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call CANBus.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call SWC_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call J1708_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call NFC_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call VERSION_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call HELP_KEY_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call audio_test.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call Temperature_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call ReadRTC_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call Accelerometer.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call GPIO_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call SUPERCAP_TEST.bat
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STSATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

rem put a field for whether all tests passed or not
if "%OBC_TEST_STSATUS%" == "Fail" (
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

if /I not %OBC_TEST_STSATUS%==PASS goto _test_failed
color 20
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
color 47

:_end_of_tests
set test_script_version=
set OBC_TEST_STSATUS=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_00%1>nul
cd ..
timeout /t 2 /NOBREAK > nul
color 07