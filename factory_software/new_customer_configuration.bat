@echo off

:_customer_number_prompt
call :print_header
echo What is the customer number?
echo.
set /p customer_number=Enter customer number:
echo.

:_part_number_prompt
call :print_header
echo Customer Number: %customer_number%
echo.

echo What is the part number?
echo  ex. MTR-A002-001, NBOARD869V3C, ...
echo.
set /p part_number=Enter part number:
echo.

:_addon_number_prompt
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo.

echo What is the addon number?
echo  ex. 0, 1, 2...
echo.
set /p addon_number=Enter the addon number:
echo.

rem Set the config file name
set "config_file_name=%part_number%_%addon_number%.dat"
if "%part_number:~0,3%"=="MTR" set "config_file_name=%part_number:~4,4%_%addon_number%.dat"

rem Check if this configuration file already exists
if exist CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%customer_number%\%config_file_name% echo Error: this configuration file already exists. Delete it to create a new one. Exiting... & goto :eof

:_os_version_prompt
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.

echo What is the required OS version?
echo.
set /p os_version=Enter the OS version:
echo.

:_mcu_version_prompt
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.
echo OS Version: %os_version%
echo.

echo What is the required MCU version?
echo  ex. A.3.6.0, A.2.C.0, ...
echo.
set /p mcu_version=Enter the MCU version:
echo.

:_fpga_version_prompt
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.
echo OS Version: %os_version%
echo MCU Version: %mcu_version%
echo.

echo What is the required FPGA version?
echo  ex. 0x41000003, ...
echo.
set /p fpga_version=Enter the FPGA version:
echo.

:_build_type_prompt
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.
echo OS Version: %os_version%
echo MCU Version: %mcu_version%
echo FPGA Version: %fpga_version%
echo.

echo What is the required OS build type?
echo     1. eng
echo     2. user-debug
echo     3. user
echo.
set /p build_type=Enter the required build type:
echo.

if "%build_type%"=="1" set "build_type=eng"
if "%build_type%"=="2" set "build_type=user-debug"
if "%build_type%"=="3" set "build_type=user"
if "%build_type%"=="eng" goto :_confirm_creation
if "%build_type%"=="user-debug" goto :_confirm_creation
if "%build_type%"=="user" goto :_confirm_creation
goto :_build_type_prompt

:_confirm_creation
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.
echo OS Version: %os_version%
echo MCU Version: %mcu_version%
echo FPGA Version: %fpga_version%
echo Build Type: %build_type%
echo.

echo Do you want to create the new configuration with these settings? [Y/N]
echo.
set /p ans=Enter Y or N:
echo.

if /I "%ans%"=="Y" goto :_create_configuration
if /I "%ans%"=="Yes" goto :_create_configuration
if /I "%ans%"=="N" goto :eof
if /I "%ans%"=="No" goto :eof

:_create_configuration
if not exist CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%customer_number% mkdir CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%customer_number%

set "filename=CUSTOMER_DEVICE_CONFIGURATION\customer_numbers\%customer_number%\%config_file_name%"
echo OS_VERSION:%os_version%>> %filename%
echo MCU_VERSION:%mcu_version%>> %filename%
echo FPGA_VERSION:%fpga_version%>> %filename%
echo BUILD_TYPE:%build_type%>> %filename%

:_display_creation
call :print_header
echo Customer Number: %customer_number%
echo Part Number: %part_number%
echo Addon Number: %addon_number%
echo.
echo OS Version: %os_version%
echo MCU Version: %mcu_version%
echo FPGA Version: %fpga_version%
echo Build Type: %build_type%
echo.

echo Created configuration file with this setup.
pause

goto :eof

:print_header
cls
echo ----------------------------------------------------
echo        New Customer Device Configuration Tool
echo ----------------------------------------------------
echo.
exit /b
