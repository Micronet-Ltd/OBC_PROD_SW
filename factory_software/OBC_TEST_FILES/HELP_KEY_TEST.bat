@echo off

set ERRORLEVEL=0

set file_name=key_test_file.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                HELP KEY            
rem echo ------------------------------------
..\adb shell echo 1014 ^> /sys/class/gpio/export

:_test_value_default
rem   ############## DEFAULT VALUE TEST ############
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
rem if exist %file_name% del %file_name%
if not %key_test%==1 goto _key_test_value1_error

rem   ############## VALUE 0 TEST ############
echo | set /p=PRESS HELP KEY on the device

set /a loop_cnt = 0

:_test_value_0
rem echo | set /p=.

set /a loop_cnt = %loop_cnt% + 1
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
if exist %file_name% del %file_name%
if %key_test% == 0 goto _test_value_1_init
if %loop_cnt% LSS 1000 goto _test_value_0
goto _key_test_value0_error

rem   ############## VALUE 1 TEST ############
:_test_value_1_init
echo.
rem echo | set /p=RELEASE HELP KEY
set /a loop_cnt = 0

:_test_value_1
rem echo | set /p=.

set /a loop_cnt = %loop_cnt% + 1
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
if exist %file_name% del %file_name%
if %key_test% == 1 goto _test_pass

if %loop_cnt% LSS 100 goto _test_value_1
goto _key_test_value1_error

rem   ############## TEST STATUS ############
:_test_pass
rem echo.
echo ** HELP KEY test - Passed
@echo HELP KEY test - passed  >> testResults\%result_file_name%.txt
goto _end_of_file


:_key_test_value1_error
set ERRORLEVEL=1
rem echo.
rem echo ****** ERROR: Expected to get 1 - got %key_test% ******
echo HELP KEY test- failed
goto _end_of_file

:_key_test_value0_error
set ERRORLEVEL=1
rem echo.
rem echo RELEASE HELP KEY
rem echo ****** ERROR: Expected to get 0 - got %key_test% ******
echo HELP KEY test- failed
@echo HELP KEY test - failed  >> testResults\%result_file_name%.txt


:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set loop_cnt= 