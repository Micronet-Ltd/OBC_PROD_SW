@echo off

set ERRORLEVEL=0

set Result= 
set imei= 
set pm_serial=
set trueIMEI=
set file_name=tmp.txt
set serial_name=serial_tmp.txt
set list_name=SerialIMEI
set tac=35483308
set matching_imei=1
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%

rem echo ------------------------------------
rem echo                IMEI test            
rem echo ------------------------------------

echo.
set "xprvar="
for /F "delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
set /p imei=%xprvar%

:_test
rem Get IMEI to a file 
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_IMEI> %file_name%

rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %file_name%

set /p Result=<%file_name%

set trueIMEI=%Result:~37,15%

rem If IMEI scanned in is same as IMEI on device then goto pass
if "%Result:~37,15%" == "%imei%" goto _tag_check
set matching_imei=-1

:_tag_check
if "%Result:~37,8%" == "%tac%" if %matching_imei% EQU 1 goto _test_pass
if "%Result:~37,8%" == "%tac%" goto _test_fail_matching
if %matching_imei% EQU 1 goto _test_fail_tac
goto _test_fail

:_test_fail_tac
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=33 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo IMEI %xprvar% matching device but tac is not correct, should be "%tac%"
setlocal DisableDelayedExpansion
rem Write result to individual device file
@echo IMEI test - failed %imei% matching device but tac is not correct, should be "%tac%" >> testResults\%result_file_name%.txt
rem Write result to summary file
<nul set /p ".='%Result:~37,15%" >> testResults\summary.csv
<nul set /p ".=," >> testResults\summary.csv
goto :_write_serial_imei

:_test_fail_matching
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=1 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
setlocal DisableDelayedExpansion
rem Write result to individual device file
@echo IMEI test - failed expected %Result:~37,15% got %imei%, tac is correct >> testResults\%result_file_name%.txt
rem Write result to summary file
<nul set /p ".='%Result:~37,15%" >> testResults\summary.csv
<nul set /p ".=," >> testResults\summary.csv
goto :_write_serial_imei

:_test_fail
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=1 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%, also tac is incorrect, should be "%tac%"
setlocal DisableDelayedExpansion
rem Write result to individual device file
@echo IMEI test - failed expected %Result:~37,15% got %imei%, also tac is incorrect, should be "%tac%" >> testResults\%result_file_name%.txt
rem Write result to summary file
<nul set /p ".='%Result:~37,15%" >> testResults\summary.csv
<nul set /p ".=," >> testResults\summary.csv
goto :_write_serial_imei

rem   ############## TEST STATUS ############
:_test_pass
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=2 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
setlocal DisableDelayedExpansion
rem Write result to individual device file
@echo IMEI test - passed %imei% >> testResults\%result_file_name%.txt
rem Write result to summary file
<nul set /p ".='%Result:~37,15%" >> testResults\summary.csv
<nul set /p ".=," >> testResults\summary.csv

:_write_serial_imei
rem write SerialNumber and IMEI to SerialIMEI.csv

rem Get uppercase Serial Number
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL> %serial_name%
rem Get the second line with the results
set "xprvar="
for /F "skip=1 delims=" %%i in (serial_tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %serial_name%
set /p Result=<%serial_name%

rem Parse serial number
set pm_serial=%Result:~37,8%

rem Write Serial and IMEI to SerialIMEI.csv
@echo %pm_serial%,%trueIMEI% >> testResults\%list_name%.csv
goto _end_of_file


:_end_of_file
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%
set Result= 
set imei= 
set pm_serial=
set trueIMEI=
set tac=
set matching_imei=