@echo off

set ERRORLEVEL=0
set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                AUDIO TEST            
rem echo ------------------------------------

:_start_test
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul 

:_right_speaker
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT --ei speaker 2 > nul
..\adb shell mctl api 0213000601 > nul rem This turns the right speaker on.
..\adb shell mctl api 0213001C00 > nul rem This turns the left speaker off.
:_right_speaker_validation
set choice=
echo.&set /p choice=Do you hear the right speaker [Y/N] ?
if /I %choice% == Y goto _left_speaker
if /I %choice% == N goto _test_fail
echo Invalid option
goto _right_speaker_validation

:_left_speaker
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT --ei speaker 1 > nul
..\adb shell mctl api 0213001C01 > nul rem This turns the left speaker on.
..\adb shell mctl api 0213000600 > nul rem This turns the right speaker off.
:_left_speaker_validation
set choice=
echo.&set /p choice=Do you hear the left speaker [Y/N] ?
if /I %choice% == Y goto _test_pass
if /I %choice% == N goto _test_fail
echo Invalid option
goto _left_speaker_validation

rem   ############## TEST STATUS ############
:_test_fail
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul 
set choice=
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _right_speaker
if /I %choice% == N goto _prepare_for_fail
echo Invalid option
goto _test_fail

:_prepare_for_fail
set ERRORLEVEL=1
echo ** Audio test - failed
@echo Audio test - failed >> testResults\%result_file_name%.txt
goto _end_of_file


:_retest
..\adb shell am start -n com.android.settings/.SoundSettings Starting: Intent { cmp=com.android.settings/.SoundSettings } > nul
timeout /T 1 /NOBREAK > nul 
goto _start_test


:_test_pass
echo ** Audio test - passed
@echo Audio test - passed  >> testResults\%result_file_name%.txt

:_end_of_file
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul


if exist %file_name% del %file_name%
set choice=
set file_name= 	
