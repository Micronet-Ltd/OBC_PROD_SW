@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set can0_fail=
set can1_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem echo ------------------------------------
rem echo               CanBus test            
rem echo ------------------------------------

:_test_loop
rem For testing, Can0 and Can1 are 'connected'
rem Result code:
rem 		 0 = app isn't installed or started, 
rem 		 1 = success, 
rem 		 2 = fail and result data will contain which ones failed,
rem In the case that one of the can ports fails to send or receive an "F" will be placed in result data instead of "P"
rem Example: A success result's data will look like "PP"
rem The first "P" is for tx out of Can0 and rx in Can1
rem The second "P" is for tx out of Can1 and rx in Can0
rem So if there is a failure then the resulting data could look like "FF":
rem The first "F" means tx out of Can0 and rx in Can1 failed
rem The second "F" means tx out of Can1 and rx in Can0 failed

rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_CAN_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

rem Result data should only be two characters long
set data=%Result:~37,2%

if "%Result:~28,1%" == "%success%" goto _test_pass

set /a loop_count=%loop_count%+1
set Result=
rem If CanBus test has failed multiple times then goto _test_fail
if %loop_count% GTR 4 goto _test_fail
echo repeat test, failure count = %loop_count%
goto _test_loop

:_test_fail
set ERRORLEVEL=1
echo  ** CanBus test - failed 
rem If one of the Can Ports failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set can0_fail="Can0 tx --> Can1 rx failed",
)
if "%data:~1,1%" == "F" (
	set can1_fail="Can1 tx --> Can0 rx failed",
)
@echo CanBus test - failed %can0_fail% %can1_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
echo ** CanBus test - passed 
@echo CanBus test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
rem Uninstall app
rem ..\adb uninstall com.micronet.obctestingapp > nul
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set can0_fail=
set can1_fail=
set loop_count=