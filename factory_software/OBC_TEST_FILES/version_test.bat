@echo off

set ERRORLEVEL=0
rem echo result file name : %result_file_name%
rem echo ------------------------------------
rem echo              VERSION TEST            
rem echo ------------------------------------

set mcu_version_file_name=input\mcu_version.dat
set fpga_version_file_name=input\fpga_version.dat
set os_version_file_name=input\os_version.dat
set version_file_name=version_file.txt

if not exist %mcu_version_file_name%  goto _test_error_no_mcu_version
if not exist %fpga_version_file_name% goto _test_error_no_fpga_version
if not exist %os_version_file_name% goto _test_error_no_os_version

:_check_MCU_version
..\adb shell mctl api 0200 > %version_file_name%
set /p version=<%version_file_name%
set version="%version:~28,7%"
set /p mcu_version=<%mcu_version_file_name%
set mcu_version="%mcu_version%"
rem echo MCU  VERSION retirvied : %version%
rem echo MCU  VERSION input     : %mcu_version%
if not %version% == %mcu_version% goto _test_error_wrong_mcu_version
@echo MCU version O.K : %mcu_version%  >> testResults\%result_file_name%.txt

:_check_FPGA_version
del %version_file_name%
..\adb shell mctl api 0201 > %version_file_name%
set /p version=<%version_file_name%
set version="%version:~9,10%"
set /p fpga_version=<%fpga_version_file_name%
set fpga_version="%fpga_version%"
rem echo FPGA VERSION retirvied : %version%
rem echo FPGA VERSION input     : %fpga_version%

if not %version% == %fpga_version% goto _test_error_wrong_fpga_version
@echo FPGA version O.K : %fpga_version%  >> testResults\%result_file_name%.txt

:_check_OS_version
del %version_file_name%
..\adb shell getprop ro.build.display.id > %version_file_name%
set /p version=<%version_file_name%
set /p os_version=<%os_version_file_name%
rem echo OS VERSION retirvied : -%version%-
rem echo OS VERSION input     : -%os_version%-

if not %version% == %os_version% goto _test_error_wrong_os_version
@echo OS version O.K : %os_version%  >> testResults\%result_file_name%.txt
if %ERRORLEVEL% == 1 goto _end_of_test

rem   ############## TEST STATUS ############
:_test_pass
echo ** version test - Passed 
goto _end_of_test

:_test_error_no_mcu_version
set ERRORLEVEL=1
echo MCU version failed 
@echo MCU version fail : expected  %mcu_version%  got %version% >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_no_fpga_version
set ERRORLEVEL=1
echo ** FPGA version test failed 
@echo FPGA version fail : expected  %fpga_version%  got %version%>> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_no_os_version
set ERRORLEVEL=1
echo ** OS version test failed 
@echo OS version failed : expected  %os_version%  got %version%>> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_wrong_mcu_version
set ERRORLEVEL=1
echo MCU version test  failed
@echo MCU version fail : expected  %mcu_version%  got %version% >> testResults\%result_file_name%.txt
goto _check_FPGA_version

:_test_error_wrong_fpga_version
set ERRORLEVEL=1
echo ** FPGA  version test  failed
@echo FPGA version fail : expected  %fpga_version%  got %version%>> testResults\%result_file_name%.txt
goto _check_OS_version

:_test_error_wrong_os_version
set ERRORLEVEL=1
echo ** OS version test  failed
@echo OS version failed : expected  %os_version%  got %version%>> testResults\%result_file_name%.txt
goto _end_of_test

:_end_of_test
if exist %version_file_name% del %version_file_name% 
set mcu_version_file_name=
set fpga_version_file_name=
set os_version_file_name=
set version_file_name=
