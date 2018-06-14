@echo off

rem ************************************************************
rem ************************ MAIN TEST *************************
rem ************************************************************
set test_script_version=1.2.39_dev
set ERRORLEVEL=0

rem Make sure all parameters passed in
set continue=
if "%1"=="" set continue=false
if "%2"=="" set continue=false
if "%3"=="" set continue=false

rem Make sure test type is system or board
if /I "%1"=="System" goto _correct_test_type
if /I "%1"=="Board" goto _correct_test_type
set continue=false
:_correct_test_type

rem Make sure test file exists
cd OBC_TEST_FILES\input\tests
if exist %3 goto _test_file_exists
set continue=false
:_test_file_exists
cd ..\..\..

if "%continue%"=="false" (
	echo.
	echo Usage: OBC_TEST_MAIN.bat [test_type] [device_info] [test_file]
	echo.
	echo *** test_type should either be "System" or "Board"
	echo *** device_info should be the info/type of device, it can be anything because it is only logged
	echo *** test_file should a test file in OBC_TEST_FILES/input/tests folder, ex. "system_tests.dat"
)
if "%continue%"=="false" goto :eof 

rem Set the test type, device type, and test file from the parameters passed in
set TEST_TYPE=%1
set DEVICE_INFO=%2
set TEST_FILE=%3

rem Prepare the test so it is ready to run
cls
call :set_up_test

echo ----------------------------------------------------------------------------------------------------
echo  starting test, test script version is : %test_script_version%, %TEST_TYPE%, %DEVICE_INFO%, %language_choice%
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
if /I "%1"=="uninstall_apps" exit /b

set column=%1
rem echo %column%

if /I "%1"=="audio_ud" set column=audio
if /I "%1"=="led_ud" set column=led

rem echo %column%

if %ERRORLEVEL% == 1 (
	set OBC_TEST_STATUS=Fail
	set %column%_test=fail
	
	setlocal EnableDelayedExpansion
	set %column%_test=fail
	call update_last_result.bat %column%_test 0
	endlocal
) else (
	call update_last_result.bat %column%_test 1
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
set rs485_test=
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

rem *************** Set Up Result Files Function ***************
:set_up_result_files
rem Set up result files depending on test type and board type

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
	call insert_result.bat
	call update_last_result.bat test_version "%test_script_version%"
	call update_last_result.bat device_info "%DEVICE_INFO%"
	
	rem Update serial
	call update_last_result.bat serial "%deviceSN%"

	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
	@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)
if /I "%TEST_TYPE%"=="Board" (
	rem Insert new result
	call insert_result.bat
	call update_last_result.bat test_version "%test_script_version%"
	call update_last_result.bat device_info "%DEVICE_INFO%"
	
	rem Update tester serial and uut serial
	call update_last_result.bat serial "%deviceSN%"
	call update_last_result.bat board_serial "%uutSerial%"
	
	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
	@echo A8 SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo UUT SN : %uutSerial%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)

call update_last_result.bat test_type "%TEST_TYPE%"
call update_last_result.bat test_file "%TEST_FILE%"

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
if "%rs485_test%" == "fail" (
	echo ** RS485 %xprvar%
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