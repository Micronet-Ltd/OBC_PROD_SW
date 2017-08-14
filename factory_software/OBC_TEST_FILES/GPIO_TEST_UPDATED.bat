@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=1
set data=
set ignition_fail=
set input1_fail=
set input2_fail=
set input3_fail=
set input4_fail=
set input5_fail=
set input6_fail=
set input7_fail=
set output0_fail=
set output1_fail=
set output2_fail=
set output3_fail=
if exist %temp_result% del %temp_result%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

rem echo ------------------------------------
rem echo               GPIO test            
rem echo ------------------------------------

:_test_loop
rem For testing, Output 0 is connected to Input 1 and 5, Output 1 is connected to Input 2 and 6, Output 2 is connected
rem to Input 3 and 7, and Output 4 is connected to Input 7. 
rem
rem Result code 0 = app isn't installed or started, 1 = success, 2 = fail and result data will contain which ones failed
rem In the case that one of the GPIO tests fail a "F" will be placed in result data instead of "P"

rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_GPIO_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

rem Data should be twelve letters total
set data=%Result:~37,12%

if "%Result:~28,1%" == "%success%" goto _test_pass
goto _ask_if_retry

set Result=
rem Don't show while it is repeating
goto _test_loop

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo  ** GPIO %xprvar% 
rem If one of the GPIO tests failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set ignition_fail="Ignition voltage was not in the range of 4000 to 14000 mv",
)
if "%data:~1,1%" == "F" (
	set input1_fail="Input 1 voltage was not in the range of 9000 to 14000 mv",
)
if "%data:~2,1%" == "F" (
	set input2_fail="Input 2 voltage was not in the range of 4000 to 5000 mv",
)
if "%data:~3,1%" == "F" (
	set input3_fail="Input 3 voltage was not in the range of 9000 to 14000 mv",
)
if "%data:~4,1%" == "F" (
	set input4_fail="Input 4 voltage was not in the range of 4000 to 5000 mv",
)
if "%data:~5,1%" == "F" (
	set input5_fail="Input 5 voltage was not in the range of 9000 to 14000 mv",
)
if "%data:~6,1%" == "F" (
	set input6_fail="Input 6 voltage was not in the range of 4000 to 5000 mv",
)
if "%data:~7,1%" == "F" (
	set input7_fail="Input 7 voltage was not in the range of 9000 to 14000 mv",
)
if "%data:~8,1%" == "F" (
	set output0_fail="Input 1 and 5 voltages not in correct range when when Output 0 set high and/or low",
)
if "%data:~9,1%" == "F" (
	set output1_fail="Input 2 and 6 voltages not in correct range when when Output 1 set high and/or low",
)
if "%data:~10,1%" == "F" (
	set output2_fail="Input 3 and 7 voltages not in correct range when when Output 2 set high and/or low",
)
if "%data:~11,1%" == "F" (
	set output3_fail="Input 4 voltage not in correct range when when Output 3 set high and/or low",
)
@echo GPIO test - failed %ignition_fail% %input1_fail% %input2_fail% %input3_fail% %input4_fail% %input5_fail% %input6_fail% %input7_fail% %output0_fail% %output1_fail% %output2_fail% %output3_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** GPIO %xprvar%
@echo GPIO test - passed >> testResults\%result_file_name%.txt
goto _end_of_file

:_ask_if_retry
set "xprvar="
for /F "skip=28 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="y" goto _test_loop
if /I "%option%"=="n" goto _test_fail
echo Invalid option
goto _ask_if_retry


:_end_of_file
rem Uninstall app
..\adb uninstall com.micronet.obctestingapp > nul
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set gpinputs_fail=
set gpo0_fail=
set gpo1_fail=
set gpo2_fail=
set gpo3_fail=