@echo off
cls
color 0f

mode con:cols=120 lines=4000

set arg1=
set arg2=
set arg3=
set arg4=

if not "%1"=="" set arg1=%1
if not "%2"=="" set arg2=%2
if not "%3"=="" set arg3=%3
if not "%4"=="" set arg4=%4

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

:_create_test_file
call :print_header
echo Creating Run_Test.bat file with these settings:
echo -Test Type: %arg1%
echo -Part Number: %arg2%
echo -Customer Number: %arg3%
echo -Addon: %arg4% & echo.

if exist Run_Test.bat del Run_Test.bat
echo @call OBC_TEST_MAIN.bat %arg1% %arg2% %arg3% %arg4% > Run_Test.bat

echo Successfully created Run_Test.bat to run the configured test.
pause
goto :eof

:print_header
cls
echo ----------------------------------------------------
echo                      Test Setup
echo ----------------------------------------------------
echo.
exit /b
