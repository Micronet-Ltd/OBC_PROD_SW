@echo off
set test_script_version=1.2.17
cls
echo ---------------------------------------------------
echo  starting test, test script version is : %test_script_version%           
echo ---------------------------------------------------

cd OBC_TEST_FILES
set OBC_TEST_STATUS=PASS

rem Variables to list which tests failed at the end
set imei_test=
set serial_test=
set version_test=
set led_test=
set sd_card_test=
set canbus_test=
set swc_test=
set j1708_test=
set com_test=
set nfc_test=
set help_key_test=
set audio_test=
set temperature_test=
set read_rtc_test=
set accelerometer_test=
set gpio_test=
set supercap_test=

rem connect to device over hotspot
call adb_CONNECT.bat %1

rem create a status file 
set result_file_name=tmp.txt
..\adb shell getprop ro.serialno > %result_file_name%
set /p deviceSN=<%result_file_name%
set mydate=%DATE:~0,10%
set result_file_name=%deviceSN%

rem start writing to individual device file
@echo. >> testResults\%result_file_name%.txt
@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt

rem add new line to summary file
echo: >>testResults\summary.csv

rem add date and device serial number to summary file
<nul set /p ".=%mydate%," >> testResults\summary.csv
<nul set /p ".=%deviceSN%," >> testResults\summary.csv

rem install test apk files
call install_files_test.bat

rem ---------- Test Start ----------
rem check that imei on barcode is the same as imei of the device
rem this batch file also writes to SerialIMEI.csv
call IMEI_TEST.bat
if %ERRORLEVEL% == 1 (
	set imei_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

rem check that serial on barcode is the same as serial of the device
call SERIAL_TEST.bat 
if %ERRORLEVEL% == 1 (
	set serial_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

rem Reset variable values
set mydate=
set deviceSN=

call VERSION_TEST.bat
if %ERRORLEVEL% == 1 (
	set version_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call LED_TEST.bat
if %ERRORLEVEL% == 1 (
	set led_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call sd-card_test_updated.bat
if %ERRORLEVEL% == 1 (
	set sd_card_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call CANBus_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set canbus_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call SWC_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set swc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call J1708_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set j1708_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call COM_TEST.bat 
if %ERRORLEVEL% == 1 (
	set com_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call NFC_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set nfc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call HELP_KEY_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set help_key_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call audio_test.bat
if %ERRORLEVEL% == 1 (
	set audio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call Temperature_TEST.bat
if %ERRORLEVEL% == 1 (
	set temperature_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call ReadRTC_TEST.bat
if %ERRORLEVEL% == 1 (
	set read_rtc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call Accelerometer_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set accelerometer_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call GPIO_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set gpio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call SUPERCAP_TEST.bat
if %ERRORLEVEL% == 1 (
	set supercap_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

rem put a field for whether all tests passed or not
if "%OBC_TEST_STATUS%" == "Fail" (
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

if /I not %OBC_TEST_STATUS%==PASS goto _test_failed
color 20
echo.
echo **************************************
echo ***** Entire OBC test passed !!! *****
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ***** Entire OBC test passed !!! ***** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
goto _end_of_tests

:_test_failed
echo.
echo **************************************
echo ********  OBC test failed !!! ********
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ********  OBC test failed !!! ******** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
color 47

echo.
echo Failed Tests (Check individual file results to see how they failed):
rem Check which tests failed and print which ones did fail
if "%imei_test%" == "fail" (
	echo ** IMEI test - failed
)
if "%serial_test%" == "fail" (
	echo ** Serial test - failed
)
if "%version_test%" == "fail" (
	echo ** Version test - failed
)
if "%led_test%" == "fail" (
	echo ** LED test - failed
)
if "%sd_card_test%" == "fail" (
	echo ** SD Card test - failed
)
if "%canbus_test%" == "fail" (
	echo ** CANBus test - failed
)
if "%swc_test%" == "fail" (
	echo ** SWC test - failed
)
if "%j1708_test%" == "fail" (
	echo ** J1708 test - failed
)
if "%com_test%" == "fail" (
	echo ** Com Port test - failed
)
if "%nfc_test%" == "fail" (
	echo ** NFC test - failed
)
if "%help_key_test%" == "fail" (
	echo ** Help Key test - failed
)
if "%audio_test%" == "fail" (
	echo ** Audio test - failed
)
if "%temperature_test%" == "fail" (
	echo ** Temperature test - failed
)
if "%read_rtc_test%" == "fail" (
	echo ** Read RTC test - failed
)
if "%accelerometer_test%" == "fail" (
	echo ** Accelerometer test - failed
)
if "%gpio_test%" == "fail" (
	echo ** GPIO test - failed
)
if "%supercap_test%" == "fail" (
	echo ** Supercap test - failed
)

:_end_of_tests
set test_script_version=
set OBC_TEST_STATUS=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_00%1>nul
cd ..
timeout /t 2 /NOBREAK > nul
color 07