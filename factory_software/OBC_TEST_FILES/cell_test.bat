@echo off

set ERRORLEVEL=0

set lowerBound=10
set upperBound=32

set temp_result=tmp.txt
set cell_fail=
set asuValue=

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo               Cellular test            
rem echo ------------------------------------

:_test_loop
rem Delete old result
if exist %temp_result% del %temp_result%

rem Check that sim card is inserted and recognized 
..\adb shell "dumpsys telephony.registry | grep -i signalstrength" > %temp_result%
for /F "tokens=2" %%G in (%temp_result%) do set /A asuValue=%%G

set cell_fail=
if %asuValue% EQU 99 (
 set cell_fail=ASU value is 99 (unknown)
)
if %asuValue% LSS %lowerBound% (
 set cell_fail=ASU value %asuValue% is less than %lowerBound%
)
if %asuValue% GTR %upperBound% (
 set cell_fail=ASU value %asuValue% is greater than %upperBound%
)

if not "%cell_fail%"=="" (
	goto _ask_if_retry
)

rem Delete old result
if exist %temp_result% del %temp_result%

rem Check that data connection is established
..\adb shell "ping -c 2 -W 2 8.8.8.8" > %temp_result%
for /F "tokens=1,6" %%G in (%temp_result%) do (
	if "%%G"=="2" set packet_loss=%%H
)

rem echo %packet_loss%

if not "%packet_loss%"=="0%%" (
	set cell_fail=Did not get a data connection
)

if not "%cell_fail%"=="" (
	goto _ask_if_retry
)

goto _test_pass


:_ask_if_retry
echo.
set /p option=%cell_fail%, would you like to retry [Y/N]:
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
echo ** Cellular test failed: %cell_fail%
@echo Cellular test - failed %cell_fail% >> testResults\%result_file_name%.txt
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
echo ** Cellular test passed: ASU = %asuValue%
@echo Cellular test - passed >> testResults\%result_file_name%.txt
goto _end_of_file

:_end_of_file
call update_last_result.bat cell_asu "%asuValue%"
if exist %temp_result% del %temp_result%
set temp_result=
set asuValue=