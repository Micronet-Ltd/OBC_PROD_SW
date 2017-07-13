@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
set total_loop_cnt=0
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                NFC test            
rem echo ------------------------------------

rem   ############## display message to the tester ############

:_full_test
echo. 
rem echo ***************************************
set "xprvar="
for /F "skip=16 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%

rem This loop count is used to wait a certain amount of time for user input
set /a loop_cnt = 0
set Result=

:_test
rem echo | set /p=.
set /a loop_cnt = %loop_cnt% + 1

..\adb shell ls -l ./sdcard/nfc.txt > %file_name%
rem Read the file size in supposed to be 888 bytes
set /p Result=<%file_name%
if %Result:~35,2% == 8 goto _Delete_File
if %Result:~35,2% == 14 goto _Delete_File
if %Result:~35,2% == 16 goto _Delete_File
if %loop_cnt% LSS 80 goto _test
goto _ask_if_retry

rem If the code reaches here that means that the text file was never generated before the timeout.
rem Increment loop.

goto _full_test

:_ask_if_retry
set "xprvar="
for /F "skip=17 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar% 
if /I "%option%"=="Y" goto _full_test
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=18 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
@echo NFC test - failed >> testResults\%result_file_name%.txt
rem Try to delete file just in case
..\adb shell rm ./sdcard/nfc.txt > nul 2>&1
goto _uninstall_apk 


:_Delete_File
set Result=
..\adb shell rm ./sdcard/nfc.txt > %file_name%
set /p Result=<%file_name%
if "%Result%" == "" goto :_uninstall_apk

set /a total_loop_cnt=%total_loop_cnt%+1

if %total_loop_cnt% GTR 2 goto _delete_failed
echo NFC test error. Try Again:
goto _full_test

:_delete_failed
set ERRORLEVEL=1
echo ** NFC delete - failed (%Result%)
@echo NFC delete failed  >> testResults\%result_file_name%.txt
goto _uninstall_apk



:_uninstall_apk
rem uninstall the apk
..\adb uninstall me.davidvassallo.nfc > nul
if %ERRORLEVEL% == 1 goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
rem echo.
set "xprvar="
for /F "skip=19 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
@echo NFC test - passed  >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set loop_cnt= 
set total_loop_cnt=