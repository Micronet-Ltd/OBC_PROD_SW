@echo off

set ERRORLEVEL=0

set lowerBound=0
set upperBound=10
set rssiLowerBound=-80

set input_file=cell_input.txt
set temp_result=tmp.txt
set success=1
set data=
set cell_fail=
set loop_count=0
if exist %temp_result% del %temp_result%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

set /p line1= <input\cell_input.dat
for /f "tokens=1,2 delims=:" %%i in ("%line1%") do (
 if %%i EQU lowAsu set /A lowerBound=%%j
 if %%i EQU highAsu set /A upperBound=%%j
)

for /F "skip=1 delims=" %%i in (input\cell_input.dat) do set "line2=%%i"
for /f "tokens=1,2 delims=:" %%i in ("%line2%") do (
 if %%i EQU lowAsu set /A lowerBound=%%j
 if %%i EQU highAsu set /A upperBound=%%j
)


rem echo ------------------------------------
rem echo               Cellular test            
rem echo ------------------------------------

:_test_loop
..\adb shell "dumpsys telephony.registry | grep -i signalstrength" > %temp_result%
for /F "tokens=2" %%G in (%temp_result%) do set /A asuValue=%%G

rem echo ASU = %asuValue%

if %asuValue% EQU 99 (
 set cell_fail="Value is 99."
 goto _ask_if_retry
)
if %lowerBound% GTR %asuValue% (
 set cell_fail=Value %asuValue% is greater than %upperBound%
 goto _ask_if_retry
)
if %upperBound% LSS %asuValue% (
 set cell_fail=Value %asuValue% is less than than %lowerBound%
 goto _ask_if_retry
)
goto _test_pass


:_ask_if_retry
set "xprvar="
for /F "skip=35 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
set /p option=%xprvar%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Cellular %xprvar%
@echo Cellular test - failed %cell_fail% >> testResults\%result_file_name%.txt
<nul set /p ".=%asuValue%," >> testResults\summary.csv
goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** Cellular %xprvar%
@echo Cellular test - passed >> testResults\%result_file_name%.txt
<nul set /p ".=%asuValue%," >> testResults\summary.csv
goto _end_of_file


:_end_of_file
if exist %temp_result% del %temp_result%
set Result= 
set success= 
set temp_result=
set data=
set loop_count=