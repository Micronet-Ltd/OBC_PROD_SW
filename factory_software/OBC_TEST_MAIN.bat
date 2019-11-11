@echo off
setlocal
cls
color 0f

mode con:cols=120 lines=4000

rem ************************************************************
rem ************************ MAIN TEST *************************
rem ************************************************************
set test_script_version=1.3.5
set ERRORLEVEL=0

rem args: RMA/Production PartNo CustomerNo
rem Make sure that all parameters are set
set continue=
set arg1=%1
set arg2=%2
set arg3=%3
set arg4=%4

call :_set_up_arguments

rem Set the main variables of the test
set TEST_INFO=%arg1%
set PART_NUMBER=%arg2%
set CUSTOMER_NUMBER=%arg3%
set ADDON=%arg4%
set "CONFIG_FILE_NAME=%arg2%_%arg4%.dat"

rem Get the test file to make sure its valid
set TEST_FILE=unknown
for /f "tokens=1,2 delims=:" %%i in (CUSTOMER_DEVICE_CONFIGURATION\part_numbers\%PART_NUMBER%.dat) do (
 if /i "%%i" == "%TEST_INFO%_TEST_FILE" set TEST_FILE=%%j
)
if "%TEST_FILE%"=="unknown" call OBC_TEST_FILES\color.bat 0c "Error: %TEST_INFO%_TEST_FILE not found in %PART_NUMBER% file... Please add test file to configuration. Exiting." & pause & goto :eof
if not exist OBC_TEST_FILES\input\tests\%TEST_FILE% call OBC_TEST_FILES\color.bat 0c "Error: Test file %TEST_FILE% not found in test folder... Please create or update configuration. Exiting." & pause & goto :eof

rem Set the test type
if /I "%TEST_INFO%"=="RMA" set "TEST_TYPE=System" & goto :_test_type_set
if /I "%TEST_FILE:~0,5%"=="board" set "TEST_TYPE=Board" & goto :_test_type_set
set "TEST_TYPE=System"
:_test_type_set

rem Get the customer settings config information
set OS_VERSION=unknown
set MCU_VERSION=unknown
set FPGA_VERSION=unknown
set BUILD_TYPE=unknown
set SERIAL_PM=unknown
for /f "tokens=1,2 delims=:" %%i in (CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%CUSTOMER_NUMBER%\%CONFIG_FILE_NAME%) do (
 if /i "%%i" == "OS_VERSION" set OS_VERSION=%%j
 if /i "%%i" == "MCU_VERSION" set MCU_VERSION=%%j
 if /i "%%i" == "FPGA_VERSION" set FPGA_VERSION=%%j
 if /i "%%i" == "BUILD_TYPE" set BUILD_TYPE=%%j
 if /i "%%i" == "SERIAL_PM" set SERIAL_PM=%%j
)
if "%OS_VERSION%"=="unknown" call OBC_TEST_FILES\color.bat 0c "Error: No OS version found in %CUSTOMER_NUMBER%.dat... Please update configuration. Exiting." & pause & goto :eof
if "%MCU_VERSION%"=="unknown" call OBC_TEST_FILES\color.bat 0c "Error: No MCU version found in %CUSTOMER_NUMBER%.dat... Please update configuration. Exiting." & pause & goto :eof
if "%FPGA_VERSION%"=="unknown" call OBC_TEST_FILES\color.bat 0c "Error: No FPGA version found in %CUSTOMER_NUMBER%.dat... Please update configuration. Exiting." & pause & goto :eof
if "%BUILD_TYPE%"=="unknown" call OBC_TEST_FILES\color.bat 0c "Error: No BUILD TYPE found in %CUSTOMER_NUMBER%.dat... Please update configuration. Exiting." & pause & goto :eof

rem Prepare the test so it is ready to run
cls
call :set_up_test

echo -----------------------------------------------------------------------------------------------------------
echo  %TEST_INFO% Test Tool: %test_script_version%, P/N: %PART_NUMBER%, Customer: %CUSTOMER_NUMBER%, Addon: %ADDON%, %language_choice%
echo.
echo  Required OS: %OS_VERSION%, MCU: %MCU_VERSION%, FPGA: %FPGA_VERSION%, OS Build Type: %BUILD_TYPE%
echo -----------------------------------------------------------------------------------------------------------

rem connect to device over hotspot
call adb_connect.bat
if %ERRORLEVEL% == 1 pause & goto :eof

rem Set up result files
call :set_up_result_files

rem Install Apps
call install_apps.bat

rem Verify that scripts haven't been altered
call unlock.bat

rem update the APN if RMA test
if "%TEST_INFO%"=="RMA" call add_new_apn.bat

rem Run tests depending on test type
for /f "delims=" %%G in (input\tests\%test_file%) do (
	if /I "%%G"=="supercap" (
		call uninstall_apps.bat
		set apps_uninstalled=True
	)

	call %%G_test.bat
	call :handle_test_result %%G
)

rem If supercap test was never called then uninstall apps now
if /I "%apps_uninstalled%"=="False" call uninstall_apps.bat

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
set column=%1
rem echo %column%

rem Handle lte and ud tests
if /I "%column:~-3%"=="_ud" set column=%column:~0,-3%
if /I "%column:~-4%"=="_lte" set column=%column:~0,-4%

rem echo %column%

if %ERRORLEVEL% == 1 (
	set OBC_TEST_STATUS=Fail
	set %column%_test=fail

	setlocal EnableDelayedExpansion
	set %column%_test=fail
	call update_last_result.bat %column%_test "0"
	endlocal
) else (
	call update_last_result.bat %column%_test "1"
)

exit /b

rem **********************************************************************************
rem **************************  Set Up Test Functions  *******************************
rem **********************************************************************************

rem ****************** Parse/Verify Arguments ********************
:_set_up_arguments

rem Make sure arg1 is populated and verified
set arg1Error=
if not "%arg1%"=="" goto :_arg_1_set
:_test_type_prompt
call :print_header
if "%arg1Error%"=="true" call OBC_TEST_FILES\color.bat 0c "Invalid test type. Enter either RMA or Production." & echo. & echo.
echo What type of test is this?
echo  1. RMA
echo  2. Production
echo.
set /p arg1=Enter test type 1 or 2:
echo.
:_arg_1_set

if /I "%arg1%"=="1" set "arg1=RMA"
if /I "%arg1%"=="2" set "arg1=Production"
if /I "%arg1%"=="rma" set "arg1=RMA" & goto _arg_1_verified
if /I "%arg1%"=="production" set "arg1=Production" & goto _arg_1_verified
set arg1Error=true
goto :_test_type_prompt
:_arg_1_verified

rem Make sure arg2 is populated and verified
set arg2Error=
if not "%arg2%"=="" goto :_arg_2_set
:_part_number_prompt
call :print_header
echo -Test Type: %arg1% & echo.
if "%arg2Error%"=="true" call OBC_TEST_FILES\color.bat 0c "Part number doesn't exist in CUSTOMER_DEVICE_CONFIGURATION folder. Either create or select a valid part number." & echo. & echo.
echo What is the part number of device are you testing?
echo  ex. MTR-A002-001, NBOARD869V3C, ...
echo.
set /p arg2=Enter part number:
echo.
:_arg_2_set

if exist CUSTOMER_DEVICE_CONFIGURATION\part_numbers\%arg2%.dat goto :_arg_2_verified
set arg2Error=true
goto :_part_number_prompt
:_arg_2_verified

rem Make sure arg3 is populated and verified
set arg3Error=
if not "%arg3%"=="" goto :_arg_3_set
:_customer_number_prompt
call :print_header
echo -Test Type: %arg1%
echo -Part Number: %arg2% & echo.
if "%arg3Error%"=="true" call OBC_TEST_FILES\color.bat 0c "Customer number doesn't exist in CUSTOMER_DEVICE_CONFIGURATION folder. Either create or select a valid customer number." & echo. & echo.
echo What is the customer number of device are you testing?
echo  Format: [customer_number]-[p/n]-[config_number]
echo  ex. 11111, 32533, 85695... Default is 00000.
echo.
set /p arg3=Enter customer number:
echo.
:_arg_3_set

if exist CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%arg3% goto :_arg_3_verified
set arg3Error=true
goto :_customer_number_prompt
:_arg_3_verified

rem Make sure arg4 is populated and verified
set arg4Error=
if not "%arg4%"=="" goto :_arg_4_set
:_addon_number_prompt
call :print_header
echo -Test Type: %arg1%
echo -Part Number: %arg2%
echo -Customer Number: %arg3% & echo.
if "%arg4Error%"=="true" call OBC_TEST_FILES\color.bat 0c "Configuration for doesn't exist in CUSTOMER_DEVICE_CONFIGURATION folder for %configFileName%. Either create or select a valid addon number." & echo. & echo.
echo What is the addon number? Default is 0.
echo  ex. 0, 1, 2...
echo.
set /p arg4=Enter addon number:
echo.
:_arg_4_set

set "configFileName=%arg2%_%arg4%.dat"
if exist CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%arg3%\%configFileName% goto :_arg_4_verified
set arg4Error=true
goto :_addon_number_prompt
:_arg_4_verified

exit /b

rem ****************** Set Up Test Function ********************
:set_up_test
rem Set up the whole test
cd OBC_TEST_FILES
set OBC_TEST_STATUS=PASS
set options_file=input\settings\test_options.dat
set apps_uninstalled=False

rem Select the language from the language file
call :language_selection

rem Reset variable values
set test=
set temp=temp.txt
if exist %temp% del %temp%

setlocal EnableDelayedExpansion
for /f "delims=" %%G in (input\tests\%test_file%) do (
	set test=%%G
	if /I "!test:~-3!"=="_ud" set test=!test:~0,-3!
	if /I "!test:~-4!"=="_lte" set test=!test:~0,-4!
	@echo !test!>>%temp%
)
endlocal

for /f "delims=" %%G in (%temp%) do (
    rem echo %%G
	set %%G_test=
)

if exist %temp% del %temp%

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
set language_file=input/languages/English.dat
exit /b

:_chinese
set language_file=input/languages/Chinese.dat
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
	echo.
	set /p uutSerial=Scan the UUT Serial Number:
	echo.
)

rem Insert result and get datetime
call insert_result.bat
call get_datetime.bat

rem Seperate so result_file_name can update
rem Batch can't update vars in if statement unless you use start local/end local
if /I "%TEST_TYPE%"=="Board" (
	rem if board test then set summary file to uut serial
	set result_file_name=%uutSerial%
)

if /I "%TEST_TYPE%"=="System" (
	call update_last_result.bat test_version "%test_script_version%"
	call update_last_result.bat part_number "%PART_NUMBER%"
	call update_last_result.bat customer_number "%CUSTOMER_NUMBER%"
  call update_last_result.bat addon_number "%ADDON%"

	rem Update serial
	call update_last_result.bat serial "%deviceSN%"

	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %datetime:"=% >> testResults\%result_file_name%.txt
	@echo Device SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)
if /I "%TEST_TYPE%"=="Board" (
	call update_last_result.bat test_version "%test_script_version%"
	call update_last_result.bat part_number "%PART_NUMBER%"
	call update_last_result.bat customer_number "%CUSTOMER_NUMBER%"
  call update_last_result.bat addon_number "%ADDON%"

	rem Update tester serial and uut serial
	call update_last_result.bat serial "%deviceSN%"
	call update_last_result.bat board_serial "%uutSerial%"

	@echo. >> testResults\%result_file_name%.txt
	@echo Test Run : %datetime:"=% >> testResults\%result_file_name%.txt
	@echo A8 SN : %deviceSN%  >> testResults\%result_file_name%.txt
	@echo UUT SN : %uutSerial%  >> testResults\%result_file_name%.txt
	@echo test script version is : %test_script_version% >> testResults\%result_file_name%.txt
)

call update_last_result.bat test_type "%TEST_TYPE%"
call update_last_result.bat test_file "%TEST_FILE%"

exit /b

rem ********************* Test Setup ***********************
:print_header
cls
echo ----------------------------------------------------
echo                  Test %test_script_version% Setup
echo ----------------------------------------------------
echo.
exit /b

rem **********************************************************************************
rem **************************  Test Finished Functions  *****************************
rem **********************************************************************************

rem ******************* Total Test Status **********************
:total_test_status
rem put a field for whether all tests passed or not
if "%OBC_TEST_STATUS%" == "Fail" (
	call update_last_result.bat all_tests "0"
) else (
	call update_last_result.bat all_tests "1"
)

if /I not %OBC_TEST_STATUS%==PASS goto _test_failed
rem color 20
echo.
set "xprvar="
for /F "skip=30 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a ************************************** & echo.
call color.bat 0a "********* " & <nul set /p =Entire %xprvar%& call color.bat 0a " *********" & echo.
call color.bat 0a ************************************** & echo.
@echo ************************************** >> testResults\%result_file_name%.txt
@echo ******* Entire test passed !!! ******* >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
exit /b

:_test_failed
echo.
set "xprvar="
for /F "skip=31 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c ************************************** & echo.
call color.bat 0c "********* " & <nul set /p =Entire %xprvar%& call color.bat 0c " *********" & echo.
call color.bat 0c ************************************** & echo.
@echo ************************************** >> testResults\%result_file_name%.txt
@echo **********  test failed !!! ********** >> testResults\%result_file_name%.txt
@echo ************************************** >> testResults\%result_file_name%.txt
rem color 47

rem Display failures
call :display_failures

rem Ask to open result files
if "%TEST_INFO%"=="RMA" call :prompt_open_result_file

exit /b

rem ******************** Display Failures **********************
:display_failures
rem Display failures from the test

echo.
set "xprvar="
for /F "skip=32 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"

rem Check which tests did fail and print them
for /f "delims=" %%G in (input\tests\%test_file%) do (
	setlocal EnableDelayedExpansion
	set test=%%G

	if /I "!test:~-3!"=="_ud" set test=!test:~0,-3!
	if /I "!test:~-4!"=="_lte" set test=!test:~0,-4!

	set test=!test!_test

	rem echo !test!

	call :display_failures !test! !test:~0,-5!
	endlocal
)

exit /b

:display_failures <var_name> <test_name>
rem echo %1
rem echo !%1!
if /I "!%1!"=="fail" call color.bat 0c "** " & echo %2 %xprvar%
exit /b

:prompt_open_result_file
set "result_file=%~dp0OBC_TEST_FILES\testResults\%deviceSN%.txt"

:_view_results_prompt
set ans=
echo.
set /p ans=Do you want to view the result file? [Y/N]:

if /I "%ans%"=="y" start notepad %result_file% & goto _valid_answer
if /I "%ans%"=="n" goto _valid_answer
goto :_view_results_prompt
:_valid_answer

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
..\adb disconnect > nul
Netsh WLAN delete profile TREQr_5_%imeiEnd%>nul
set imeiEnd=
cd testResults
rem Update the csv files.
call export_results.bat
cd ..
cd ..
timeout /t 2 /NOBREAK > nul
rem color 07
pause
exit /b
