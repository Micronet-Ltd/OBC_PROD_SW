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
set tac2=35740708
set tac3=86987502
set matching_imei=1
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%

rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

rem echo ------------------------------------
rem echo                IMEI test
rem echo ------------------------------------

rem if defined tempIMEI set imei=%tempIMEI%
rem if defined tempIMEI goto _test

echo.
set "xprvar="
for /F "delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0b "-> "
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
if "%Result:~37,15%" == "%imei%" goto _tac_check
set matching_imei=-1

:_tac_check
if "%Result:~37,8%" == "%tac%" if %matching_imei% EQU 1 goto _test_pass
if "%Result:~37,8%" == "%tac2%" if %matching_imei% EQU 1 goto _test_pass
if "%Result:~37,8%" == "%tac3%" if %matching_imei% EQU 1 goto _test_pass
if "%Result:~37,8%" == "%tac%" goto _test_fail_matching
if "%Result:~37,8%" == "%tac2%" goto _test_fail_matching
if "%Result:~37,8%" == "%tac3%" goto _test_fail_matching
if %matching_imei% EQU 1 goto _test_fail_tac
goto _test_fail

:_test_fail_tac
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo IMEI %xprvar% matching device but tac is not correct, should be "%tac%", "%tac2%", or "%tac3%"
endlocal
rem Write result to individual device file
@echo IMEI test - failed %imei% matching device but tac is not correct, should be "%tac%", "%tac2%", or "%tac3%" >> testResults\%result_file_name%.txt
rem Write result to database
call update_last_result.bat imei "%Result:~37,15%"
goto :_write_serial_imei

:_test_fail_matching
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=1 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo %xprvar%
endlocal
rem Write result to individual device file
@echo IMEI test - failed expected %Result:~37,15% got %imei%, tac is correct >> testResults\%result_file_name%.txt
rem Write result to database
call update_last_result.bat imei "%Result:~37,15%"
goto :_write_serial_imei

:_test_fail
set ERRORLEVEL=1
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=1 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo %xprvar%, also tac is incorrect, should be "%tac%", "%tac2%", or "%tac3%"
endlocal
rem Write result to individual device file
@echo IMEI test - failed expected %Result:~37,15% got %imei%, also tac is incorrect, should be "%tac%", "%tac2%", or "%tac3%" >> testResults\%result_file_name%.txt
rem Write result to database
call update_last_result.bat imei "%Result:~37,15%"
goto :_write_serial_imei

rem   ############## TEST STATUS ############
:_test_pass
setlocal EnableDelayedExpansion
set "xprvar="
for /F "skip=2 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo %xprvar%
endlocal
rem Write result to individual device file
@echo IMEI test - passed %imei% >> testResults\%result_file_name%.txt
rem Write result to database
call update_last_result.bat imei "%Result:~37,15%"

:_write_serial_imei
rem Get and parse the serial number
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL> %serial_name%
rem Parse second line of result on double quotes to get serial number whether it is 7 or 8 digits long.
set "xprvar="
for /F delims^=^"^ tokens^=2^ skip^=1 %%i in (serial_tmp.txt) do if not defined xprvar set "xprvar=%%i"
set serialNum=%xprvar%

rem Write Serial and IMEI to SerialIMEI.csv
rem @echo %serialNum%,%trueIMEI% >> testResults\%list_name%.csv

rem Check for possible duplicate Serial/IMEI
set tempIMEI='%trueIMEI%
set passedVar=pass
set tempResult=0
rem call :duplicate tempResult %serialNum% %tempIMEI%
rem echo The result is %tempResult%

if "%tempResult%"=="1" goto _ask_if_continue
rem echo no duplicates found, continuing
goto :_end_of_file

:_ask_if_continue
set "xprvar="
for /F "skip=38 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _continue
if /I "%option%"=="N" goto _exit
echo Invalid option
goto _ask_if_continue

:_continue
echo Continuing testing.
goto :_end_of_file

:_exit
set "xprvar="
for /F "skip=39 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
echo Exiting test ...
set ERRORLEVEL=2
goto :_end_of_file

:_end_of_file
if exist %file_name% del %file_name%
if exist %serial_name% del %serial_name%
set Result=
set imei=
set pm_serial=
set tac=
set tac2=
set tac3=
set matching_imei=
set serialNum=
set passedVar=
set tempResult=
goto :eof

:duplicate <resultVar> <serialNum> <imei>
rem echo %1 %2 %3

for /F "tokens=2,3,29 delims=," %%A in (%summaryFile%) do (
    rem @echo %%A %%B %%C
    if /I "%2"=="%%A" if /I "%passedVar%"=="%%C" (
        set %1=1
        rem echo Possible duplicate found maybe
    )

    if /I "%3"=="%%B" if /I "%passedVar%"=="%%C" (
        set %1=1
        rem echo Possible duplicate found maybe
    )
)
exit /b
