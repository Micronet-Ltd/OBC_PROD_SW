@echo off

set test_script_version=1.2.26
set ERRORLEVEL=0

cls
echo ---------------------------------------------------
echo  starting test, test script version is : %test_script_version%           
echo ---------------------------------------------------

cd OBC_TEST_FILES
set OBC_TEST_STATUS=PASS

:_language_selection
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
goto _continue_test

:_chinese
set language_file=input/Chinese.txt
goto _continue_test

:_continue_test
rem Variables to list which tests failed at the end
set imei_test=
set serial_test=
set version_test=
set led_test=
set sd_card_test=
set cellular_test=
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
set wiggle_test=
set supercap_test=

rem connect to device over hotspot
call adb_CONNECT.bat %1
 
rem create a status file 
set result_file_name=tmp.txt
..\adb shell getprop ro.serialno > %result_file_name%
set /p deviceSN=<%result_file_name%

rem check to make sure serialNumber is eight digits long and if it isn't then add a 0 to the front of it
set tempSerial=%deviceSN%
call :strLen serialLen tempSerial
if "%serialLen%"=="7" (set deviceSN=0%tempSerial%)

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
if %ERRORLEVEL% == 2 (
	echo Exiting from main test file...
	<nul set /p ".=fail," >> testResults\summary.csv
) 
if %ERRORLEVEL% == 2 exit /b
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

call Cellular.bat
if %ERRORLEVEL% == 1 (
	set cellular_test=fail
	set OBC_TEST_STATUS=Fail
	<nul set /p ".=fail," >> testResults\summary.csv
) else (
	<nul set /p ".=pass," >> testResults\summary.csv
)

call WIFI_TEST.bat
if %ERRORLEVEL% == 1 (
	set WiFi_test=fail
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

call WIGGLE_TEST.bat
if %ERRORLEVEL% == 1 (
    set wiggle_test=fail
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

:_end_of_tests
set test_script_version=
set OBC_TEST_STATUS=
set language_choice_file=
set language_choice=
set language_file=
..\adb disconnect
Netsh WLAN delete profile TREQr_5_00%1>nul
cd ..
timeout /t 2 /NOBREAK > nul
color 07
goto :eof

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