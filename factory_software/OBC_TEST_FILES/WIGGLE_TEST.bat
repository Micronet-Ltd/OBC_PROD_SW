@echo off
 
:_start_test
set ERRORLEVEL=0
 
set file_name=tmp.txt
if exist %file_name% del %file_name%
 
rem echo ------------------------------------
rem echo                Wiggle Test            
rem echo ------------------------------------
 
set /a loop_cnt = 0
 
rem Open wiggle
..\adb shell mctl api 021501 > nul
 
echo Wiggle Test - Tap the device
 
:_test_Wiggle
 
set /a loop_cnt = %loop_cnt% + 1
 
rem Sample
..\adb shell mctl api 0216 > %file_name%
 
set %wiggleCount%=
set /p wiggleCount=<%file_name%
set /a wiggleCount=%wiggleCount:~17,3%
 
if %wiggleCount% GTR 1 if %wiggleCount% LSS 5000 goto _test_passed
 
if %loop_cnt% LSS 80 goto _test_Wiggle
goto _ask_if_retry
 
:_single_fail
@echo Wiggle test - failed wiggle Count = %wiggleCount% >> testResults\%result_file_name%.txt
:_
set choice=
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _start_test
goto _error_found
 
:_test_passed
echo ** Wiggle test - passed Count=%wiggleCount%
@echo Wiggle test - passed wiggle Count=%wiggleCount% >> testResults\%result_file_name%.txt
goto _end_of_file
 
:_error_found
set ERRORLEVEL=1
echo.
echo ** Wiggle test - failed wiggle Count=%wiggleCount%
 
:_end_of_file
rem Close wiggle
..\adb shell mctl api 021500 > nul
if exist %file_name% del %file_name%
set file_name= 
set wiggleCount= 
set choice=
set loop_cnt=