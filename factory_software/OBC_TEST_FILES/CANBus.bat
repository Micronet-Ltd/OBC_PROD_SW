@echo off

set ERRORLEVEL=0

set file_name=tmp.txt
rem if exist %file_name% del %file_name%
rem echo ------------------------------------
rem echo                CANBus Test            
rem echo ------------------------------------
:_CANBus
rem goto _aa
rem open can1
rem ..\adb shell slcan_tty  in the new os do it with out data folder
..\adb shell slcan_tty -c -o1 -f -s5 /dev/ttyACM2 > nul

rem open can2
rem ..\adb shell slcan_tty  in the new os do it with out data folder
..\adb shell slcan_tty -c -o1 -f -s5 /dev/ttyACM3 > nul

rem do the test 
rem ..\adb shell slcan_tty -Y0 > nul
..\adb shell slcan_tty -Y0  > nul

rem get the log file from the device to log.txt file 
..\adb shell cat /data/cantest/log1.txt > %file_name%
rem remove the CR form the can results 
call :_stripCR

set /p log=<%file_name%
rem :_aa
rem set /p log=<newfile.txt
rem check the string size
call :strlen size log
rem echo %size%,%log%
if %size% LSS 30 goto _CanTest_error


set readstring=%log:~1,11%
set writestring=%log:~19,11%
rem echo %readstring% , %writestring%
if %readstring% NEQ %writestring% goto :_CanTest_error

:_test_pass
@echo ** CANBus test - passed
@echo CANBus test - passed >> testResults\%result_file_name%.txt
goto _end_of_file

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)
:_stripCR
SetLocal DisableDelayedExpansion
for /f "tokens=*" %%a in ('find /n /v "" ^< %file_name%') do (
    set line=%%a
    SetLocal EnableDelayedExpansion
    set line=!line:*]=!

    rem "set /p" won't take "=" at the start of a line....
    if "!line:~0,1!"=="=" set line= !line!
    
    rem there must be a blank line after "set /p"
    rem and "<nul" must be at the start of the line
    set /p =!line!^

<nul
    endlocal
) > %file_name%
exit /b

:_CanTest_error
set ERRORLEVEL=1
@echo ** CANBus test - failed
@echo CANBus test - failed >> testResults\%result_file_name%.txt



:_end_of_file
if exist %file_name% del %file_name%
set log=
set size=
set file_name= 
set readstring=
set writestring=