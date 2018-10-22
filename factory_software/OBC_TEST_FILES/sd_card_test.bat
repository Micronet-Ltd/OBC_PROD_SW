@echo off

:_start_test
set ERRORLEVEL=0

set file_name=tmp.txt
set loop_count=0
if exist %file_name% del %file_name%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat

rem echo ------------------------------------
rem echo                SD Card Test            
rem echo ------------------------------------


:_test_start
..\adb shell ls ./storage/sdcard1/ > %file_name%
rem Read the first 14 characters to see if get an error 
set /p Result=<%file_name%
rem If there is no 'opendir failed' error then continue with test
if not "%Result:~0,14%" == "opendir failed" goto :_Copy_file

:_no_sd_card
set choice=
set "xprvar="
for /F "skip=9 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
rem Increment loop count
rem set /a loop_count=%loop_count%+1
rem If SD Card test has failed multiple times then goto _test_fail_no_sd_card
rem if %loop_count% GTR 2 goto _test_fail_no_sd_card
set "xprvar="
for /F "skip=10 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I %choice% == Y goto _test_start
if /I %choice% == N goto _test_fail_no_sd_card
echo Invalid option
goto _no_sd_card

:_test_fail_no_sdcard
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo SD-Card %xprvar%
@echo SD-Card test - failed can't find SD card. (%Result%)>> testResults\%result_file_name%.txt
goto _end_of_file

:_Copy_file
..\adb push .\INSTALL_FILES\sd-card_test.txt ./storage/sdcard1/ > nul 2>&1

:_File_size
..\adb shell ls -l ./storage/sdcard1/sd-card_test.txt > %file_name%
rem Read the file size in supposed to be 888 bytes
set /p Result=<%file_name%
if %Result:~35,2% == 18 goto _Delete_File

rem Increment loop count
rem set /a loop_count=%loop_count%+1
set "xprvar="
for /F "skip=11 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo %xprvar%
rem If SD Card test has failed multiple times then goto _test_fail_unexpected_size
rem if %loop_count% GTR 2 goto _test_fail_unexpected_size
rem Ask user if they want to repeat the test.
:_unexpected_size_prompt
set choice=
set "xprvar="
for /F "skip=10 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I %choice% == Y goto _test_start
if /I %choice% == N goto _test_fail_unexpected_size
echo Invalid option
goto _unexpected_size_prompt

:_test_fail_unexpected_size
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo SD-card %xprvar%
@echo SD-card test - failed - SD card not found or didn't get the expected size >> testResults\%result_file_name%.txt
goto _end_of_file

:_Delete_File
set Result=
..\adb shell rm ./storage/sdcard1/sd-card_test.txt > %file_name%
set /p Result=<%file_name%
if "%Result%" == "" goto _Test_pass

rem Increment loop count
set /a loop_count=%loop_count%+1
rem If SD Card test has failed multiple times then goto _test_fail_delete_failed
if %loop_count% GTR 2 goto _test_fail_delete_
rem else Copy file again and try to check file size
goto _test_start

:_test_fail_delete_failed
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo SD-card %xprvar%
@echo SD-card delete failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_Test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo SD-card %xprvar%
@echo SD-card test passed >> testResults\%result_file_name%.txt
goto _end_of_file

:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set Result= 
set choice=
set loop_count=