@echo off

set ERRORLEVEL=0
set file_name=tmp.txt
if exist %file_name% del %file_name%
rem If language file is not set then default to english
if not defined language_file set language_file=input/languages/English.dat

rem echo ------------------------------------
rem echo                AUDIO UD TEST
rem echo ------------------------------------

rem Tests the external speaker on the UD unit
:_start_test
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT > nul

:_external_speaker_validation
set choice=
set "xprvar="
for /F "skip=41 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo.&set /p choice=%xprvar%
if /I %choice% == Y goto _test_pass
if /I %choice% == N goto _ask_if_retry
echo Invalid option
goto _external_speaker_validation

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

:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo Audio %xprvar%
@echo Audio test - passed  >> testResults\%result_file_name%.txt

:_end_of_file
if exist %file_name% del %file_name%
set choice=
set file_name=
