@echo off
cls
color 0f

:_test_type
call :print_header

echo What type of test is this?
echo  1. System
echo  2. Board
echo.
set /p test_type=Enter test type 1 or 2: 
echo.

if "%test_type%"=="1" set test_type=System
if "%test_type%"=="2" set test_type=Board

:_device_type
call :print_header
echo Test Type: %test_type%
echo.

echo What type of device are you testing?
echo  ex. MTR-A002-001, SmartCradle, NBOARD869V3C, ...
echo.
set /p device_type=Enter device info: 
echo.

:_test_file
call :print_header
echo Test Type: %test_type%
echo Device Info: %device_type%
echo.

echo What test file are you using?
echo.

setlocal EnableDelayedExpansion
cd OBC_TEST_FILES\input\tests

set /a i=1
for /f %%i in ('dir /b') do (
  echo      !i!. %%i
  set test_files[!i!]=%%i
  set /a i=!i!+1
)

cd ../../..

echo.
set /p choice=Enter the test file number: 
set var=%%test_files[%choice%]%%
call echo %var% > tmp.txt
endlocal

set /p test_file=<tmp.txt
del tmp.txt

:_test_info
call :print_header
echo Test Type: %test_type%
echo Device Info: %device_type%
echo Test File: %test_file%
echo.

echo Is the test a Production or RMA test?
echo  1. Production
echo  2. RMA
echo.
set /p test_info=Enter test info [1/2]: 
echo.

if "%test_info%"=="1" set test_info=Production
if "%test_info%"=="2" set test_info=RMA

:_create_test_file
call :print_header
echo Creating Run_Test.bat file with these settings:
echo    - Test Type: %test_type%
echo    - Device Type: %device_type%
echo    - Test File: %test_file%
echo    - Test Info: %test_info%
echo.

if exist Run_Test.bat del Run_Test.bat
echo @call OBC_TEST_MAIN.bat %test_type% %device_type% %test_file% %test_info% > Run_Test.bat

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