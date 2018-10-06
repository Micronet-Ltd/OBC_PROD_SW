@echo off

set temp_result=tmp.txt
if exist %temp_result% del %temp_result%

@For /F "tokens=*" %%a IN ('"dir /s /a /-c "*.bat"| find "bytes" | find /v "free""') do @Set summaryout=%%a
::@Echo %summaryout%

@For /f "tokens=1,2 delims=)" %%a in ("%summaryout%") do @set filesout=%%a&set sizeout=%%b

@Set sizeout=%sizeout:bytes=%
::@Echo %sizeout%

@Set sizeout=%sizeout: =%
rem @Echo Total Size in (BYTES) :%sizeout%
rem ..\adb shell am broadcast -a com.micronet.obctestingapp.GET_UNLOCK_HASH  --es "fileSize" %sizeout%
..\adb shell am broadcast -a com.micronet.obctestingapp.CHECK_UNLOCK_HASH --es "fileSize" %sizeout% --es "hash" 54359574 > %temp_result%

rem Get result code
set "xprvar="
for /F "skip=1 delims=" %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"
echo %xprvar% > %temp_result%
set /p unlocked=<%temp_result%

set unlocked=%unlocked:~28,1%

rem Make sure files are correct size
if "%unlocked%" == "2" echo Testing scripts have been altered. Cannot run test. Exiting... & goto _exit_test

if exist %temp_result% del %temp_result%
goto :eof

:_exit_test
call :halt 2> nul

:halt
()
exit /b
