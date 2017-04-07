@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                NFC test            
rem echo ------------------------------------

rem   ############## display message to the tester ############

echo. 
rem echo ***************************************
echo NFC test - Get ready with NFC card
pause
echo Touch the device with NFC tag
set /a loop_cnt = 0

:_test
rem echo | set /p=.
set /a loop_cnt = %loop_cnt% + 1

..\adb shell ls -l ./sdcard/nfc.txt > %file_name%
rem Read the file size in supposed to be 888 bytes
set /p Result=<%file_name%
if %Result:~35,2% == 8 goto _Delete_File
if %Result:~35,2% == 14 goto _Delete_File
if %Result:~35,2% == 16 goto _Delete_File
if %loop_cnt% LSS 300 goto _test

set ERRORLEVEL=1
echo  ** NFC test - failed 
@echo NFC test - failed >> testResults\%result_file_name%.txt


:_Delete_File
set Result=
..\adb shell rm ./sdcard/nfc.txt > %file_name%
set /p Result=<%file_name%
if "%Result%" == "" goto :_uninstall_apk
set ERRORLEVEL=1
echo ** NFC delete - failed (%Result%)
@echo NFC delete failed  >> testResults\%result_file_name%.txt

:_uninstall_apk
rem uninstall the apk
..\adb uninstall me.davidvassallo.nfc > nul
if %ERRORLEVEL% == 1 goto :_end_of_file

rem   ############## TEST STATUS ############
:_test_pass
rem echo.
echo ** NFC test - passed
@echo NFC test - passed  >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set loop_cnt= 