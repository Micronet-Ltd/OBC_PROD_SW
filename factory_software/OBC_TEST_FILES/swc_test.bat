@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set swc_fail=
set loop_count=0
if exist %temp_result% del %temp_result%
rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

rem echo ------------------------------------
rem echo               SWC test
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

rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SWC_RESULT> %temp_result%
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
if loop_count LSS 8 goto _test_loop
goto _ask_if_retry

:_ask_if_retry
set "xprvar="
for /F "skip=13 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo SWC %xprvar%
rem If SWC test failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set swc_fail="SWC failed: tx out of Can1 did not rx a succesful response in Can1",
)
@echo SWC test - failed %swc_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo SWC %xprvar%
@echo SWC test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set Result=
set success=
set temp_result=
set data=
set can0_fail=
set can1_fail=
set loop_count=
