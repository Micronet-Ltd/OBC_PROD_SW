@echo off

rem ************************************************************
rem ************************ MAIN TEST *************************
rem ************************************************************
set test_script_version=1.2.35
set ERRORLEVEL=0

cls
echo ---------------------------------------------------
echo  starting test, test script version is : %test_script_version%           
echo ---------------------------------------------------

cd OBC_TEST_FILES
set OBC_TEST_STATUS=PASS

rem Select the language from the language file
call :language_selection

rem Reset variable values
call :reset_result_variables

rem Select the test type and device type from the dat file
call :test_type_selection

rem connect to device over hotspot
call adb_CONNECT.bat

rem Set up result files
call :set_up_results

rem install test apk files
call install_files_test.bat

rem Run tests depending on test type
if "%TEST_TYPE%"=="System" call :system_test
if "%TEST_TYPE%"=="Board" call :board_test

:_total_test_status
rem put a field for whether all tests passed or not
if "%OBC_TEST_STATUS%" == "Fail" (
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
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
goto _end_of_tests

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

if "%TEST_TYPE%"=="System" call :display_system_failures
if "%TEST_TYPE%"=="Board" call :display_board_failures

:_end_of_tests
set test_script_version=
set OBC_TEST_STATUS=
set language_choice_file=
set language_choice=
set language_file=
set TEST_TYPE=
set summaryFile=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_%imeiEnd%>nul
set imeiEnd=
cd ..
timeout /t 2 /NOBREAK > nul
color 07
goto :eof


rem ************************************************************
rem ******************* SYSTEM TEST Function *******************
rem ************************************************************
:system_test
rem Function used to run all tests used in the system test

call IMEI_TEST.bat
if %ERRORLEVEL% == 2 (
	echo Exiting from main test file...
	<nul set /p ".=fail," >> %summaryFile%
) 
if %ERRORLEVEL% == 2 exit /b
if %ERRORLEVEL% == 1 (
	set imei_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

set tempIMEI=

rem check that serial on barcode is the same as serial of the device
call SERIAL_TEST.bat 
if %ERRORLEVEL% == 1 (
	set serial_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

rem Reset variable values
set mydate=
set deviceSN=

call VERSION_TEST.bat
if %ERRORLEVEL% == 1 (
	set version_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call LED_TEST.bat
if %ERRORLEVEL% == 1 (
	set led_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call sd-card_test_updated.bat
if %ERRORLEVEL% == 1 (
	set sd_card_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call Cellular.bat
if %ERRORLEVEL% == 1 (
	set cellular_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call WIFI_TEST.bat
if %ERRORLEVEL% == 1 (
	set WiFi_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call GPS_TEST.bat
if %ERRORLEVEL% == 1 (
	set gps_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call CANBus_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set canbus_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call SWC_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set swc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call J1708_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set j1708_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

if /I "%DEVICE_TYPE%"=="MTR-A002-001" goto com_test
if /I "%DEVICE_TYPE%"=="MTR-A003-001" goto com_test
<nul set /p ".=N/A," >> %summaryFile%
goto skip_com_test

:com_test
call COM_TEST.bat 
if %ERRORLEVEL% == 1 (
	set com_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

:skip_com_test

call NFC_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set nfc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call HELP_KEY_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set help_key_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call audio_test.bat
if %ERRORLEVEL% == 1 (
	set audio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call Temperature_TEST.bat
if %ERRORLEVEL% == 1 (
	set temperature_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call ReadRTC_TEST.bat
if %ERRORLEVEL% == 1 (
	set read_rtc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call Accelerometer_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set accelerometer_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

if /I "%DEVICE_TYPE%"=="MTR-A001-001" goto gpio_a001_test

call GPIO_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set gpio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)
goto wiggle_test

:gpio_a001_test
call GPIO_TEST.bat
if %ERRORLEVEL% == 1 (
	set gpio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

:wiggle_test
call WIGGLE_TEST.bat
if %ERRORLEVEL% == 1 (
    set wiggle_test=fail
    set OBC_TEST_STATUS=Fail
    <nul set /p ".=fail," >> %summaryFile%
) else (
    <nul set /p ".=pass," >> %summaryFile%
)

call SUPERCAP_TEST.bat
if %ERRORLEVEL% == 1 (
	set supercap_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

exit /b


rem ************************************************************
rem ******************* BOARD TEST Function ********************
rem ************************************************************
:board_test
rem Runs all the tests that are used to test the board test

rem check that serial on barcode is the same as serial of the device
call BOARD_SERIAL_TEST.bat 
if %ERRORLEVEL% == 1 (
	set serial_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

rem Reset variable values
set mydate=
set deviceSN=

rem Only mcu/fpga
call VERSION_TEST.bat
if %ERRORLEVEL% == 1 (
	set version_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call LED_TEST.bat
if %ERRORLEVEL% == 1 (
	set led_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call CANBus_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set canbus_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call SWC_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set swc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call J1708_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set j1708_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

rem Depends on the board.
call COM_TEST.bat 
if %ERRORLEVEL% == 1 (
	set com_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call HELP_KEY_TEST_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set help_key_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

rem Are they plugging in speakers?
call audio_test.bat
if %ERRORLEVEL% == 1 (
	set audio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call Temperature_TEST.bat
if %ERRORLEVEL% == 1 (
	set temperature_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call ReadRTC_TEST.bat
if %ERRORLEVEL% == 1 (
	set read_rtc_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call Accelerometer_UPDATED.bat
if %ERRORLEVEL% == 1 (
	set accelerometer_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call GPIO_TEST.bat
if %ERRORLEVEL% == 1 (
	set gpio_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

call WIGGLE_TEST.bat
if %ERRORLEVEL% == 1 (
    set wiggle_test=fail
    set OBC_TEST_STATUS=Fail
    <nul set /p ".=fail," >> %summaryFile%
) else (
    <nul set /p ".=pass," >> %summaryFile%
)

rem Might not work, needs to charge. Set up of test?
call SUPERCAP_TEST.bat
if %ERRORLEVEL% == 1 (
	set supercap_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> %summaryFile%
) else (
	<nul set /p ".=pass," >> %summaryFile%
)

exit /b

rem ************************************************************
rem ************** Launguage Selection Function ****************
rem ************************************************************
:language_selection
rem Used to selection the language from the language file

set language_choice_file=
set language_choice=
set language_file=

set language_choice_file=input/language.dat

set /p language_choice=<%language_choice_file%
set language_choice=%language_choice%

if /I "%language_choice%" == "English" goto _english
if /I "%language_choice%" == "Chinese" goto _chinese
echo.
echo Error: input/language.dat file contains invalid value. 
echo Should either be "English" or "Chinese"
echo Defaulting to English
echo.
goto _english

:_english
set language_file=input/English.txt
exit /b

:_chinese
set language_file=input/Chinese.txt
exit /b


rem ************************************************************
rem ************** Test Type Selection Function ****************
rem ************************************************************
:test_type_selection
rem Check whether this is a board test or a system test and set variable

set /p line1= <input\TEST_TYPE.dat
for /f "tokens=1,2 delims=:" %%i in ("%line1%") do (
 if %%i EQU TEST_TYPE set TEST_TYPE=%%j
)

set /p line1= <input\DEVICE_TYPE.dat
for /f "tokens=1,2 delims=:" %%i in ("%line1%") do (
 if %%i EQU DEVICE_TYPE set DEVICE_TYPE=%%j
)

if /I "%TEST_TYPE%"=="System" (
	echo Starting a system test.
	set summaryFile=testResults\summary.csv
)
if /I "%TEST_TYPE%"=="Board" (
	echo Starting a board test.
	set summaryFile=testResults\boardSummary.csv
)
rem if /I "%DEVICE_TYPE%"=="MTR-A001-001" (
	rem echo Device type is MTR-A001-001.
rem )
rem if /I "%DEVICE_TYPE%"=="MTR-A002-001" (
	rem echo Device type is MTR-A002-001.
rem )
rem if /I "%DEVICE_TYPE%"=="MTR-A003-001" (
	rem echo Device type is MTR-A003-001.
rem )

exit /b

rem ************************************************************
rem **************** Result Variables Function *****************
rem ************************************************************
:reset_result_variables
rem Reset result variables
set imei_test=
set serial_test=
set version_test=
set led_test=
set sd_card_test=
set cellular_test=
set canbus_test=
set WiFi_test=
set gps_test=
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
set wiggle_test=
set supercap_test=

exit /b

rem ************************************************************
rem *************** Set Up Result Files Function ***************
rem ************************************************************
:set_up_results
rem Set up result files

rem Get serial number
set result_file_name=tmp.txt
..\adb shell getprop ro.serialno > %result_file_name%
set /p deviceSN=<%result_file_name%

rem Set result file name to serial number
set mydate=%DATE:~0,10%
set result_file_name=%deviceSN%

rem start writing to individual device file
@echo. >> testResults\%result_file_name%.txt
@echo Test Run : %DATE:~0,10% %TIME% >> testResults\%result_file_name%.txt
@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt

rem add new line to summary file
echo: >>%summaryFile%

rem add date and device serial number to summary file
<nul set /p ".=%mydate%," >> %summaryFile%
<nul set /p ".=%DEVICE_TYPE%," >> %summaryFile%
<nul set /p ".=%deviceSN%," >> %summaryFile%

exit /b


rem ************************************************************
rem ******************* strLen TEST Function *******************
rem ************************************************************
:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)

rem ************************************************************
rem ****************** Display Board Failures ******************
rem ************************************************************
:display_board_failures
rem Display failures from the board test

echo.
set "xprvar="
for /F "skip=32 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
rem Check which tests failed and print which ones did fail
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
if "%cellular_test%" == "fail" (
	echo ** Cellular %xprvar%
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
if "%help_key_test%" == "fail" (
	echo ** Help Key %xprvar%
)
if "%audio_test%" == "fail" (
	echo ** Audio %xprvar%
)
if "%temperature_test%" == "fail" (
	echo ** Temperature %xprvar%
)
if "%read_rtc_test%" == "fail" (
	echo ** Read RTC %xprvar%
)
if "%accelerometer_test%" == "fail" (
	echo ** Accelerometer %xprvar%
)
if "%gpio_test%" == "fail" (
	echo ** GPIO Inputs %xprvar%
)
if "%wiggle_test%" == "fail" (
    echo ** Wiggle %xprvar%
)
if "%supercap_test%" == "fail" (
	echo ** Supercap %xprvar%
)

exit /b


rem ************************************************************
rem ***************** Display System Failures ******************
rem ************************************************************
:display_system_failures
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
if "%cellular_test%" == "fail" (
	echo ** Cellular %xprvar%
)
if "%WiFi_test%" == "fail" (
	echo ** WiFi %xprvar%
)
if "%gps_test%" == "fail" (
	echo ** GPS %xprvar%
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
if "%read_rtc_test%" == "fail" (
	echo ** Read RTC %xprvar%
)
if "%accelerometer_test%" == "fail" (
	echo ** Accelerometer %xprvar%
)
if "%gpio_test%" == "fail" (
	echo ** GPIO %xprvar%
)
if "%wiggle_test%" == "fail" (
    echo ** Wiggle %xprvar%
)
if "%supercap_test%" == "fail" (
	echo ** Supercap %xprvar%
)

exit /b