@echo off

set ERRORLEVEL=0
set file_name=tmp.txt
if exist %file_name% del %file_name%
rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

rem echo ------------------------------------
rem echo                AUDIO TEST
rem echo ------------------------------------

echo.
echo About to perform Audio test...

:_start_test
set HASFAILED=0
set LEFTFAIL=0
set RIGHTFAIL=0

:_right_speaker
rem The propagation delay from sending broadcast message till audio is played is something
rem that may differ between one test to another.
rem When CPU plays audio, it enables both speakers. In this test the left speaker needs to
rem be disabled after the audio start playing.
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT --ei speaker 1 > nul

:_right_speaker_validation
set choice=
set "xprvar="
for /F "skip=23 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.
call color.bat 0b "-> "
set /p choice=%xprvar%
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
rem The propagation delay from sending broadcast message till audio is played is something
rem that may differ between one test to another.
rem When CPU plays audio, it enables both speakers. In this test the reight speaker needs to
rem be disabled after the audio start playing.
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT --ei speaker 2 > nul

:_left_speaker_validation
set choice=
set "xprvar="
for /F "skip=24 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.
call color.bat 0b "-> "
set /p choice=%xprvar%
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
for /F "skip=25 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p option=%xprvar%
if /I "%option%"=="Y" goto _start_test
if /I "%option%"=="N" goto _prepare_for_fail
echo Invalid option
goto _ask_if_retry

:_prepare_for_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo Audio %xprvar%
@echo Audio test - failed >> testResults\%result_file_name%.txt

goto _end_of_file

:_retest
..\adb shell am start -n com.android.settings/.SoundSettings Starting: Intent { cmp=com.android.settings/.SoundSettings } > nul
timeout /T 1 /NOBREAK > nul
goto _start_test


:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo Audio %xprvar%
@echo Audio test - passed  >> testResults\%result_file_name%.txt

:_end_of_file
rem These turn off both speakers.
..\adb shell mctl api 0213000600 > nul
..\adb shell mctl api 0213001C00 > nul


if exist %file_name% del %file_name%
set choice=
set file_name=
