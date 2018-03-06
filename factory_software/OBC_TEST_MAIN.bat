@echo off

rem ************************************************************
rem ************************ MAIN TEST *************************
rem ************************************************************
set test_script_version=1.2.38
set ERRORLEVEL=0

rem Prepare the test so it is ready to run
call :set_up_test

cls
echo ----------------------------------------------------------------------------------------------------
echo  starting test, test script version is : %test_script_version%, %TEST_TYPE%, %DEVICE_TYPE%, %language_choice%
echo ----------------------------------------------------------------------------------------------------

rem connect to device over hotspot
call adb_connect.bat
rem Set up result files
call :set_up_result_files
rem install test apk files
call install_files.bat

rem Run tests depending on test type
for /f "delims=" %%G in (input\tests\%test_file%) do (
	call %%G_test.bat
	call :handle_test_result %%G
)

rem Handle total test result
call :total_test_status

rem Handle test post processing
call :end_of_test

goto :eof

rem **********************************************************************************
rem ****************************  Testing Functions  *********************************
rem **********************************************************************************

rem ************** Handle Test Result Function *****************
:handle_test_result <test_var>
if %ERRORLEVEL% == 1 (
	set OBC_TEST_STATUS=Fail
	set %1_test=fail
	
	setlocal EnableDelayedExpansion
	set %1_test=fail
	call update_last_result.bat %1_test 0
	endlocal
) else (
	call update_last_result.bat %1_test 1
)

exit /b

rem **********************************************************************************
rem **************************  Set Up Test Functions  *******************************
rem **********************************************************************************

rem ****************** Set Up Test Function ********************
:set_up_test
rem Set up the whole test
cd OBC_TEST_FILES
set OBC_TEST_STATUS=PASS
set options_file=input\test_options.dat

rem Select the language from the language file
call :language_selection

rem Reset variable values
call :reset_result_variables

rem Select the test type and device type from the dat file
call :test_selection

exit /b

rem ************** Language Selection Function *****************
:language_selection
rem Used to selection the language from the language file

set language_choice_file=
set language_choice=
set language_file=

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "LANGUAGE" set language_choice=%%j
)

if /I "%language_choice%" == "English" goto _english
if /I "%language_choice%" == "Chinese" goto _chinese
echo.
echo Error: input/test_options.dat file contains invalid language value. 
echo Should either be "English" or "Chinese". Defaulting to English.
echo.
goto _english

:_english
set language_file=input/English.dat
exit /b

:_chinese
set language_file=input/Chinese.dat
exit /b


rem ************** Test Selection Function *********************
:test_selection
rem Select test
set TEST_FILE=
set DEVICE_TYPE=
set SUMMARY_FILE=
set TEST_TYPE=

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "TEST_FILE" set TEST_FILE=%%j
)

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "SUMMARY_FILE" set SUMMARY_FILE=%%j
)

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "DEVICE_TYPE" set DEVICE_TYPE=%%j
)

for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
 if /i "%%i" == "TEST_TYPE" set TEST_TYPE=%%j
)

if /I "%TEST_TYPE%"=="System" (
	if /I "%DEVICE_TYPE%"=="MTR-A001-001" set TEST_FILE=system_a001_tests.dat
	if /I "%DEVICE_TYPE%"=="MTR-A002-001" set TEST_FILE=system_tests.dat
	if /I "%DEVICE_TYPE%"=="MTR-A003-001" set TEST_FILE=system_tests.dat
	if /I "%DEVICE_TYPE%"=="UD" set TEST_FILE=system_ud_tests.dat
)
if /I "%TEST_TYPE%"=="Board" (
	if /I "%DEVICE_TYPE%"=="MTR-A001-001" set TEST_FILE=board_tests.dat
	if /I "%DEVICE_TYPE%"=="MTR-A002-001" set TEST_FILE=board_tests.dat
	if /I "%DEVICE_TYPE%"=="MTR-A003-001" set TEST_FILE=board_tests.dat
	if /I "%DEVICE_TYPE%"=="UD" set TEST_FILE=board_ud_tests.dat
)

exit /b

rem **************** Result Variables Function *****************
:reset_result_variables
rem Reset result variables
set imei_test=
set serial_test=
set version_test=
set led_test=
set sd_card_test=
set canbus_test=
set wifi_test=
set swc_test=
set j1708_test=
set com_test=
set nfc_test=
set help_key_test=
set audio_test=
set temperature_test=
set rtc_test=
set accelerometer_test=
set gpio_test=
set wiggle_test=
set supercap_test=

exit /b

rem *************** Set Up Result Files Function ***************
:set_up_result_files
rem Set up result files depending on test type and board type
set summaryFile=

rem Make sure DB is set up
call create_tables.bat

rem Get serial number
set result_file_name=tmp.txt
..\adb shell getprop ro.serialno > %result_file_name%
set /p deviceSN=<%result_file_name%
set mydate=%DATE:~0,10%

if /I "%TEST_TYPE%"=="System" (
	rem if system test then set summary file to serial number
	set result_file_name=%deviceSN%
)
if /I "%TEST_TYPE%"=="Board" (
	rem if board test then set summary file to uut serial
	set /p uutSerial=Scan the uut Serial Number: 
	echo.
)

rem Seperate so result_file_name can update
rem Batch can't update vars in if statement unless you use start local/end local
if /I "%TEST_TYPE%"=="Board" (
	rem if board test then set summary file to uut serial
	set result_file_name=%uutSerial%
)

if /I "%TEST_TYPE%"=="System" (
	rem Insert new result
	call insert_result.bat system_results
	call update_last_result.bat test_version '%test_script_version%'
	call update_last_result.bat device_type '%DEVICE_TYPE%'
	
	rem Update serial
	call update_last_result.bat serial '%deviceSN%'

	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
	@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)
if /I "%TEST_TYPE%"=="Board" (
	rem Insert new result
	call insert_result.bat board_results
	call update_last_result.bat test_version '%test_script_version%'
	call update_last_result.bat device_type '%DEVICE_TYPE%'
	
	rem Update tester serial and uut serial
	call update_last_result.bat a8_serial '%deviceSN%'
	call update_last_result.bat uut_serial '%uutSerial%'
	
	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
	@echo A8 SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo UUT SN : %uutSerial%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)

exit /b

rem **********************************************************************************
rem **************************  Test Finished Functions  *****************************
rem **********************************************************************************

rem ******************* Total Test Status **********************
:total_test_status
rem put a field for whether all tests passed or not
if "%OBC_TEST_STATUS%" == "Fail" (
	call update_last_result.bat all_tests 0
) else (
	call update_last_result.bat all_tests 1
)

if /I not %OBC_TEST_STATUS%==PASS goto _test_failed
color 20
echo.
set "xprvar="
for /F "skip=30 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo **************************************
echo ***** Entire OBC %xprvar% !!! *****
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ***** Entire OBC test passed !!! ***** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
exit /b

:_test_failed
echo.
set "xprvar="
for /F "skip=31 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo **************************************
echo ********  OBC %xprvar% !!! ********
echo **************************************
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ********  OBC test failed !!! ******** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
color 47

rem Display failures
call :display_failures

exit /b

rem ******************** Display Failures **********************
:display_failures
rem Display failures from the system test

echo.
set "xprvar="
for /F "skip=32 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
rem Check which tests failed and print which ones did fail
if "%imei_test%" == "fail" (
	echo ** IMEI %xprvar%
)
if "%serial_test%" == "fail" (
	echo ** Serial %xprvar%
)
if "%version_test%" == "fail" (
	echo ** Version %xprvar%
)
if "%led_test%" == "fail" (
	echo ** LED %xprvar%
)
if "%sd_card_test%" == "fail" (
	echo ** SD Card %xprvar%
)
if "%wifi_test%" == "fail" (
	echo ** WiFi %xprvar%
)
if "%canbus_test%" == "fail" (
	echo ** CANBus %xprvar%
)
if "%swc_test%" == "fail" (
	echo ** SWC %xprvar%
)
if "%j1708_test%" == "fail" (
	echo ** J1708 %xprvar%
)
if "%com_test%" == "fail" (
	echo ** Com Port %xprvar%
)
if "%nfc_test%" == "fail" (
	echo ** NFC %xprvar%
)
if "%help_key_test%" == "fail" (
	echo ** Help Key %xprvar%
)
if "%audio_test%" == "fail" (
	echo ** Audio %xprvar%
)
if "%temperature_test%" == "fail" (
	echo ** Temperature %xprvar%
)
if "%rtc_test%" == "fail" (
	echo ** Read RTC %xprvar%
)
if "%accelerometer_test%" == "fail" (
	echo ** Accelerometer %xprvar%
)
if "%gpio_test%" == "fail" (
	echo ** GPIO %xprvar%
)
if "%gpio_inputs_test%" == "fail" (
	echo ** GPIO Inputs %xprvar%
)
if "%wiggle_test%" == "fail" (
    echo ** Wiggle %xprvar%
)
if "%supercap_test%" == "fail" (
	echo ** Supercap %xprvar%
)

exit /b

rem ******************** Display Failures **********************
:end_of_test
set test_script_version=
set OBC_TEST_STATUS=
set language_choice_file=
set language_choice=
set language_file=
set TEST_TYPE=
set summaryFile=
set uutSerial=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_%imeiEnd%>nul
set imeiEnd=
cd testResults
rem Update the csv files.
call export_results.bat
cd ..
cd ..
timeout /t 2 /NOBREAK > nul
color 07

exit /b