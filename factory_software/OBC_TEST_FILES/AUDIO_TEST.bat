@echo off

set ERRORLEVEL=0
set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                AUDIO TEST            
rem echo ------------------------------------

:_start_test
set HASFAILED=0
set LEFTFAIL=0
set RIGHTFAIL=0
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul 

:_right_speaker
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT > nul
..\adb shell mctl api 0213000601 > nul rem This turns the right speaker on.
..\adb shell mctl api 0213001C00 > nul rem This turns the left speaker off.

:_right_speaker_validation
set choice=
set "xprvar="
for /F "skip=23 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I %choice% == Y goto _left_speaker
if /I %choice% == N goto _right_test_fail
echo Invalid option
goto _right_speaker_validation

:_right_test_fail
set HASFAILED=1
set RIGHTFAIL=1
@echo Audio right speaker test - failed >> testResults\%result_file_name%.txt
goto :_left_speaker

:_left_speaker
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT > nul
..\adb shell mctl api 0213001C01 > nul rem This turns the left speaker on.
..\adb shell mctl api 0213000600 > nul rem This turns the right speaker off.

:_left_speaker_validation
set choice=
set "xprvar="
for /F "skip=24 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I %choice% == Y goto _evaluate
if /I %choice% == N goto _left_test_fail
echo Invalid option
goto _left_speaker_validation

:_left_test_fail
set HASFAILED=1
set LEFTFAIL=1
@echo Audio left speaker test - failed >> testResults\%result_file_name%.txt
goto _evaluate

:_evaluate
if %HASFAILED% EQU 1 goto _ask_if_retry
goto _test_pass

:_ask_if_retry
set "xprvar="
for /F "skip=25 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _start_test
if /I "%option%"=="N" goto _prepare_for_fail
echo Invalid option
goto _ask_if_retry

:_prepare_for_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo ** Audio %xprvar%
@echo Audio test - failed >> testResults\%result_file_name%.txt

goto _end_of_file

:_retest
..\adb shell am start -n com.android.settings/.SoundSettings Starting: Intent { cmp=com.android.settings/.SoundSettings } > nul
timeout /T 1 /NOBREAK > nul 
goto _start_test


:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (input/LANGUAGE.txt) do if not defined xprvar set "xprvar=%%i"
echo ** Audio %xprvar%
@echo Audio test - passed  >> testResults\%result_file_name%.txt

:_end_of_file
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul


if exist %file_name% del %file_name%
set choice=
set file_name= 	
