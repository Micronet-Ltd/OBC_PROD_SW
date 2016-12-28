@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
rem echo ------------------------------------
rem echo         acceleromete Test            
rem echo ------------------------------------

:_test_acceleromete
echo | set /p=move the device ...  
rem pause> nul 
..\adb shell "testframe > /sdcard/acceleromete.txt 2>&1 &"
timeout /T 6 /NOBREAK > nul
..\adb shell  ls -la /sdcard/acceleromete.txt>%file_name%
set /p accelerometer=<%file_name%
rem echo file name: %file_name%
rem echo all return %accelerometer%
set accelerometer=%accelerometer:~30,7%
rem echo only size %accelerometer%

..\adb shell  rm /sdcard/acceleromete.txt

rem check the file size 
if %accelerometer% LSS 500 goto _accelerometer_size_error 

echo ** accelerometer test - passed
@echo accelerometer test - passed  accelerometer file size is: %accelerometer%  >> testResults\%result_file_name%.txt
goto _end_of_file

:_accelerometer_size_error
echo ** accelerometer test - failed
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _test_acceleromete
set ERRORLEVEL=1
@echo accelerometer test - failed file size grater then 3000 got %accelerometer% >> testResults\%result_file_name%.txt

:_end_of_file
if exist %file_name% del %file_name%

set file_name= 
set accelerometer= 