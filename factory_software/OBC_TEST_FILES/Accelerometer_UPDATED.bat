@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set accel_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

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

set Result=
goto _ask_if_retry

:_ask_if_retry
set "xprvar="
for /F "skip=27 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
set /p option=%xprvar%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Accelerometer %xprvar%
rem If Accelerometer test failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set accel_fail="Invalid accelerometer %Result:~31%",
)
@echo Accelerometer test - failed %accel_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Accelerometer %xprvar%
@echo Accelerometer test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
rem if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set loop_count=