@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set loop_count=0
if exist %temp_result% del %temp_result%

rem echo ------------------------------------
rem echo               Com Ports test            
rem echo ------------------------------------

:_test_loop
rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_COM_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

if "%Result:~28,1%" == "%success%" goto _test_pass

set /a loop_count=%loop_count%+1
set Result=
rem If com port test has failed multiple times then goto _test_fail
if %loop_count% GTR 4 goto _test_fail
echo Repeat test, failure count = %loop_count%
goto _test_loop

:_test_fail
set ERRORLEVEL=1
echo  ** Com Port test - failed 
@echo Com Port test - failed >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
echo ** Com Port test - passed 
@echo Com Port test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set Result= 
set success= 