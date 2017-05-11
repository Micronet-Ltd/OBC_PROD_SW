@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set accel_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem echo ------------------------------------
rem echo               Accelerometer test            
rem echo ------------------------------------

:_test_loop
rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_ACCEL_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

rem Result data should only be one character long
set data=%Result:~37,1%

if "%Result:~28,1%" == "%success%" goto _test_pass

set /a loop_count=%loop_count%+1
rem If Accelerometer test has failed multiple times then goto _test_fail
if %loop_count% GTR 7 goto _test_fail
rem echo repeat test, failure count = %loop_count%
set Result=

goto _test_loop

:_test_fail
set ERRORLEVEL=1
echo  ** Accelerometer test - failed 
rem If Accelerometer test failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set accel_fail="Invalid accelerometer %Result:~31%",
)
@echo Accelerometer test - failed %accel_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
echo ** Accelerometer test - passed 
@echo Accelerometer test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set loop_count=