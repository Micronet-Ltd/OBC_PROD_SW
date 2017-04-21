@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set j1708_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem echo ------------------------------------
rem echo               J1708 test            
rem echo ------------------------------------

:_test_loop
rem For testing, Can1 (/dev/ttyACM3) is 'connected' to another board that it is communicating on
rem Result code:
rem 		 0 = app isn't installed or started, 
rem 		 1 = success, 
rem 		 2 = fail and result data will contain which ones failed,
rem In the case that one of the can ports fails to send or receive an "F" will be placed in result data instead of "P"
rem Example: A success result's data will look like "P"
rem The "P" is for tx out of Can1 and a successful response rx in Can1
rem So if there is a failure then the resulting data would look like "F":
rem The "F" means tx out of Can1 and not a succesful response rx in Can1

rem Enable j1708 power
rem Might already be enabled at this point
..\adb shell "mctl api 0213020001" > nul

rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_J1708_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

rem Result data should only be one character long
set data=%Result:~37,1%

if "%Result:~28,1%" == "%success%" goto _test_pass

set /a loop_count=%loop_count%+1
set Result=
rem If SWC test has failed multiple times then goto _test_fail
if %loop_count% GTR 4 goto _test_fail
echo repeat test, failure count = %loop_count%
goto _test_loop

:_test_fail
set ERRORLEVEL=1
echo  ** J1708 test - failed 
rem If SWC test failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set j1708_fail="J1708 failed: did not receive j1708 chars back",
)
@echo J1708 test - failed %swc_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
echo ** J1708 test - passed 
@echo J1708 test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
rem Uninstall app
rem ..\adb uninstall com.micronet.obctestingapp > nul
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set j1708_fail=
set loop_count=