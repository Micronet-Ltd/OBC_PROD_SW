@echo off

set ERRORLEVEL=0

set file_name=key_test_file.txt
if exist %file_name% del %file_name%

set key_test=
set total_loop_count=0

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo                HELP KEY            
rem echo ------------------------------------

echo.

..\adb shell echo 1014 ^> /sys/class/gpio/export

:_test_value_default
rem   ############## DEFAULT VALUE TEST ############
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
if not %key_test%==1 goto _initial_value_test_failed


:_tester_prompt
if exist %file_name% del %file_name%
rem   ############## VALUE 0 TEST ############
set "xprvar="
for /F "skip=20 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo | set /p=%xprvar%

rem Loop counter used for timeout on each test attempt
set /a loop_cnt = 0

:_test_value_0_button_pressed
rem echo | set /p=.

set /a loop_cnt = %loop_cnt% + 1
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
if exist %file_name% del %file_name%


if %key_test% == 0 goto _test_value_1_init
if %loop_cnt% LSS 300 goto _test_value_0_button_pressed

rem Increment loop count
set /a total_loop_count=%total_loop_count%+1
rem If Help Key test has failed multiple times then goto _key_test_value0_error
if %total_loop_count% GTR 2 goto _key_test_value0_error

echo.
echo No button press detected. Try again:
echo.
goto _tester_prompt

rem   ############## VALUE 1 TEST ############
:_test_value_1_init
rem echo.
rem echo | set /p=RELEASE HELP KEY
set /a loop_cnt = 0

:_test_value_1
rem echo | set /p=.

set /a loop_cnt = %loop_cnt% + 1
..\adb shell cat /sys/class/gpio/gpio1014/value > %file_name%

set /p key_test=<%file_name%
if exist %file_name% del %file_name%
rem Value is correct so test pass
if %key_test% == 1 goto _test_pass
rem Repeat and check value
if %loop_cnt% LSS 100 goto _test_value_1

rem Increment loop count
set /a total_loop_count=%total_loop_count%+1
rem If SD Card test has failed multiple times then goto _test_fail_unexpected_size
if %total_loop_count% GTR 2 goto _key_test_value1_error

echo.
echo Key press state not changed. Please release help key after press. Try Again:
goto _tester_prompt

rem   ############## TEST STATUS ############
:_test_pass
echo.
set "xprvar="
for /F "skip=21 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
@echo Help Key test - passed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_initial_value_test_failed
set ERRORLEVEL=1
set "xprvar="
for /F "skip=22 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% : Initial Help Key state incorrect
@echo Help Key test - failed : Initial Help Key state incorrect >> testResults\%result_file_name%.txt
goto _end_of_file

:_key_test_value1_error
set ERRORLEVEL=1
echo.
set "xprvar="
for /F "skip=22 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% : After Help Key press state not changed back to unpressed
@echo Help Key test - failed : After Help Key press state not changed back to unpressed >> testResults\%result_file_name%.txt
goto _end_of_file

:_key_test_value0_error
set ERRORLEVEL=1
echo.
set "xprvar="
for /F "skip=22 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% : Help Key press never detected
@echo Help Key test - failed : Help Key press never detected  >> testResults\%result_file_name%.txt


:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set loop_cnt= 