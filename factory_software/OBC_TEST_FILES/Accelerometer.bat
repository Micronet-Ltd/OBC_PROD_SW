@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
set loop_count=0
rem echo ------------------------------------
rem echo         Accelerometer Test            
rem echo ------------------------------------

:_test_acceleromete
echo | set /p=move the device ...  
rem pause> nul 
..\adb shell "testframe > /sdcard/acceleromete.txt 2>&1 &"
timeout /T 4 /NOBREAK > nul
..\adb shell  ls -la /sdcard/acceleromete.txt>%file_name%
set /p accelerometer=<%file_name%
rem echo %accelerometer% 
rem echo file name: %file_name%
rem echo all return %accelerometer%
rem echo %accelerometer:~30,7%
set accelerometer=%accelerometer:~30,7%
rem echo %accelerometer%

rem Kill testframe
..\adb shell "busybox pkill testframe" > nul
..\adb shell rm /sdcard/acceleromete.txt

rem check the file size 
if %accelerometer% LSS 1000 goto _accelerometer_size_error 

echo.
echo ** Accelerometer test - passed
@echo Accelerometer test - passed  accelerometer file size is: %accelerometer%  >> testResults\%result_file_name%.txt
goto _end_of_file

:_accelerometer_size_error
rem Increment loop count
set /a loop_count=%loop_count%+1
rem If run more than 4 times then fail test
if %loop_count% GTR 3 goto _test_fail
goto _test_acceleromete

echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _test_acceleromete

:_test_fail
set ERRORLEVEL=1
echo.
echo ** Accelerometer test - failed
@echo Accelerometer test - failed : expected file size greater then 1000 got %accelerometer% >> testResults\%result_file_name%.txt

:_end_of_file
if exist %file_name% del %file_name%

set file_name= 
set accelerometer= 