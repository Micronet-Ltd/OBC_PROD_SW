@echo off

set ERRORLEVEL=0

set temp_result=tmp.txt
set success=PPFF
set data=
set com1_fail=
set com2_fail=
set com3_fail=
set com4_fail=
set loop_count=0
if exist %temp_result% del %temp_result%
rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo               Com Ports test            
rem echo ------------------------------------

rem Disable RS485
rem ..\adb shell "mctl api 0213041b00" > nul
..\adb shell "echo 1 > /sys/class/switch/dock/rs485_en" > nul
:_test_loop
rem For testing, Com 1 and Com 2 are 'connected' and Com 3 and Com 4 are 'connected'
rem Result code 0 = app isn't installed or started, 1 = success, 2 = fail and result data will contain which ones failed
rem In the case that one of the com ports fails to send or receive an "F" will be placed in result data instead of "P"
rem Example: A success result's data will look like "PPPP"
rem The first "P" is for tx out of Com 1 and rx in Com 2
rem The second "P" is for tx out of Com 2 and rx in Com 1
rem The third "P" is for tx out of Com 3 and rx in Com 4
rem The fourth "P" is for tx out of Com 4 and rx in Com 3
rem So if there is a failure then the resulting data could look like "FFPP":
rem The first "F" means tx out of Com 1 and rx in Com 2 failed
rem The second "F" means tx out of Com 2 and rx in Com 1 failed
rem The first "P" means tx out of Com 3 and rx in Com 4 was successful
rem The second "P" means tx out of Com 4 and rx in Com 3 was successful

rem Send broadcast to run test and get result
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_COM_RESULT> %temp_result%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p Result=<%temp_result%

set data=%Result:~37,4%
rem remove below
rem echo  ** Result %Result%
if "%Result:~37,4%" == "%success%" goto _test_pass

set /a loop_count=%loop_count%+1
set Result=
goto _ask_if_retry

:_ask_if_retry
set "xprvar="
for /F "skip=15 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
echo %data%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo  ** Com Port %xprvar%
rem If one of the Com Ports failed then write that to the test result file
if "%data:~0,1%" == "F" (
	set com1_fail="Com 1 tx --> Com 2 rx failed",
	echo %com1_fail%;
)
if "%data:~1,1%" == "F" (
	set com2_fail="Com 2 tx --> Com 1 rx failed",
)
if "%data:~2,1%" == "F" (
	set com3_fail="Com 3 tx --> Com 4 rx failed",
)
if "%data:~3,1%" == "F" (
	set com4_fail="Com 4 tx --> Com 3 rx failed",
)
@echo Com Port test - failed %com1_fail% %com2_fail% %com3_fail% %com4_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Com Port %xprvar% 
@echo Com Port test - passed >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set com1_fail=
set com2_fail=
set com3_fail=
set com4_fail=
set loop_count=