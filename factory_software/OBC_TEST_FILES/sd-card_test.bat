@echo off

:_start_test
set ERRORLEVEL=0

set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                SD Card Test            
rem echo ------------------------------------


:_is_sdcard_exits
..\adb shell 'ls ./storage/sdcard1/' > %file_name%
rem Read the first 14 characters to see if get an error 
set /p Result=<%file_name%
if not "%Result:~0,14%" == "opendir failed" goto :_Copy_file

set choice=
echo SD card error can't find the SD card
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _is_sdcard_exits
set ERRORLEVEL=1
echo  ** SD-Card test - failed 
@echo SD-Card test - failed can't find SD card. (%Result%)>> testResults\%result_file_name%.txt
goto _end_of_file

:_Copy_file
..\adb push .\INSTALL_FILES\sd-card_test.txt ./storage/sdcard1/ > nul 2>&1

:_File_size
..\adb shell ls -l ./storage/sdcard1/sd-card_test.txt > %file_name%
rem Read the file size in supposed to be 888 bytes
set /p Result=<%file_name%
if %Result:~35,2% == 18 goto _Delete_File
set ERRORLEVEL=1
echo  SD-card  test failed 
@echo SD-card  test failed - didn't get the expected size >> testResults\%result_file_name%.txt
goto _end_of_file

:_Delete_File
set Result=
..\adb shell rm ./storage/sdcard1/sd-card_test.txt > %file_name%
set /p Result=<%file_name%
if "%Result%" == "" goto _Test_pass
set ERRORLEVEL=1
echo  SD-card delete failed 
@echo SD-card delete failed  >> testResults\%result_file_name%.txt
goto _end_of_file

:_Test_pass
echo ** SD-card test passed
@echo SD-card test passed >> testResults\%result_file_name%.txt
goto _end_of_file

:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set Result= 
set choice=