@echo off

set ERRORLEVEL=0
rem echo result file name : %result_file_name%
rem echo ------------------------------------
rem echo              VERSION TEST
rem echo ------------------------------------

set fpga_version_file_name=input\fpga_version.dat
set os_version_file_name=input\os_version.dat
set version_file_name=version_file.txt

rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

:_check_MCU_version
..\adb shell mctl api 0200 > %version_file_name%
set /p version=<%version_file_name%
set version=%version:~28,7%

if not %version% == %MCU_VERSION% goto _test_error_wrong_mcu_version
@echo MCU version O.K : %MCU_VERSION%  >> testResults\%result_file_name%.txt

call update_last_result.bat mcu_ver '%version%'

:_check_FPGA_version
del %version_file_name%
..\adb shell mctl api 0201 > %version_file_name%
set /p version=<%version_file_name%
set version=%version:~9,10%

if not %version% == %FPGA_VERSION% goto _test_error_wrong_fpga_version
@echo FPGA version O.K : %FPGA_VERSION%  >> testResults\%result_file_name%.txt

call update_last_result.bat fpga_ver '%version%'

:_check_OS_version
del %version_file_name%
..\adb shell getprop ro.build.display.id > %version_file_name%
set /p version=<%version_file_name%

if not %version% == %OS_VERSION% goto _test_error_wrong_os_version
@echo OS version O.K : %OS_VERSION%  >> testResults\%result_file_name%.txt

call update_last_result.bat os_ver '%version%'

:_check_build_type
del %version_file_name%
..\adb shell getprop ro.build.type > %version_file_name%
set /p build=<%version_file_name%

if not %build% == %BUILD_TYPE% goto _test_error_wrong_build_type
@echo Build Type O.K : %BUILD_TYPE%  >> testResults\%result_file_name%.txt

call update_last_result.bat build_type '%build%'

if %ERRORLEVEL% == 1 goto _end_of_test

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo Version %xprvar%
goto _end_of_test

:_test_error_no_mcu_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo MCU version %xprvar% : Error, no MCU version string in the input folder. Contact MICRONET for the MCU string
@echo MCU version - failed : There is no MCU version string in the input folder. Contact MICRONET for the MCU string >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_no_fpga_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo FPGA version %xprvar% : Error no FPGA version string in the input folder. Contact MICRONET for the FPGA string
@echo FPGA version - failed : There is no FPGA version string in the input folder. Contact MICRONET for the FPGA string >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_no_os_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo OS version %xprvar% : Error, no OS version string in the input folder. Contact MICRONET for the OS string
@echo OS version - failed : There is no OS version string in the input folder. Contact MICRONET for the OS string >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_error_wrong_mcu_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo MCU version %xprvar% : expected %mcu_version% got %version%. Burn correct MCU version.
@echo MCU version - failed : expected %mcu_version% got %version%. Burn correct MCU version. >> testResults\%result_file_name%.txt

call update_last_result.bat mcu_ver '%version%'
goto _check_FPGA_version

:_test_error_wrong_fpga_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo FPGA version %xprvar% : expected %fpga_version% got %version%. Burn correct FPGA version.
@echo FPGA version - failed : expected  %fpga_version%  got %version%. Burn correct FPGA version. >> testResults\%result_file_name%.txt

call update_last_result.bat fpga_ver '%version%'

goto _check_OS_version

:_test_error_wrong_os_version
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo OS version %xprvar% : expected %os_version% got %version%. Burn correct OS version.
@echo OS version - failed : expected  %os_version%  got %version%. Burn correct OS version. >> testResults\%result_file_name%.txt

call update_last_result.bat os_ver '%version%'

goto _check_build_type

:_test_error_wrong_build_type
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo Build type version %xprvar% : expected %BUILD_TYPE% got %build%. Burn correct OS version.
@echo Build type version - failed : expected  %BUILD_TYPE%  got %build%. Burn correct OS version. >> testResults\%result_file_name%.txt

call update_last_result.bat build_type '%build%'

goto _end_of_test

:_end_of_test
if exist %version_file_name% del %version_file_name%
set mcu_version_file_name=
set fpga_version_file_name=
set os_version_file_name=
set version_file_name=
