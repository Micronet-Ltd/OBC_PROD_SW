@echo off

set ERRORLEVEL=0
set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                AUDIO TEST            
rem echo ------------------------------------

rem ..\adb shell am start -a android.intent.action.VIEW -d file:///data/local/tmp/track56.mp3 -t audio/mp3 > nul
..\adb shell am start -n com.android.settings/.SoundSettings Starting: Intent { cmp=com.android.settings/.SoundSettings } > nul
timeout /T 1 /NOBREAK > nul 
..\adb shell input keyevent 20

:_start_test
..\adb shell input keyevent 20
..\adb shell input keyevent 20
..\adb shell input keyevent 20
..\adb shell input keyevent 20
..\adb shell input keyevent 20
rem ..\adb shell input keyevent 20



rem turning off both speakers 
rem ..\adb shell mctl api 0213000600 > nul
rem ..\adb shell mctl api 0213001C00 > nul 
rem ..\adb shell input keyevent 86  

:_right_speaker
rem ..\adb shell am start -a android.intent.action.VIEW -d file:///data/local/tmp/track56.mp3 -t audio/mp3 > nul
..\adb shell input keyevent 66
rem Turning off the left  speaker 
..\adb shell mctl api 0213001C00 > nul
set choice=
echo.&set /p choice=Do you hear the right speaker [Y/N] ?
if /I %choice% NEQ Y goto _test_fail

:_left_speaker
rem ..\adb shell am start -a android.intent.action.VIEW -d file:///data/local/tmp/track56.mp3 -t audio/mp3 > nul
..\adb shell input keyevent 66
rem Turning off the right speaker 
..\adb shell mctl api 0213000600 > nul 
rem Turning on the left speaker 
..\adb shell mctl api 0213001C01 > nul
set choice=
echo.&set /p choice=Do you hear the left speaker [Y/N] ?
if /I %choice% == Y goto _test_pass


rem   ############## TEST STATUS ############
:_test_fail
rem mute the music with back command
..\adb shell input keyevent 4
set choice=
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _retest 
set ERRORLEVEL=1
echo ** audio test - failed
@echo audio  test - failed >> testResults\%result_file_name%.txt
goto _end_of_file


:_retest
..\adb shell am start -n com.android.settings/.SoundSettings Starting: Intent { cmp=com.android.settings/.SoundSettings } > nul
timeout /T 1 /NOBREAK > nul 
goto _start_test


:_test_pass
echo ** audio test - passed
@echo audio test - passed  >> testResults\%result_file_name%.txt

:_end_of_file
rem turning on both speakers 
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul 
rem mute the music with back command
..\adb shell input keyevent 4


if exist %file_name% del %file_name%
set choice=
set file_name= 	
