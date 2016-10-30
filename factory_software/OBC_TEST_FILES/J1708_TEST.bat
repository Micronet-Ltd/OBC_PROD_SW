@echo off
set ERRORLEVEL=0
rem setlocal enabledelayedexpansion
set j1708_file=j1708_device.log
set /A failure_count=0

..\adb root > nul
..\adb connect 192.168.43.1 > nul
..\adb wait-for-device > nul
timeout /T 1 /NOBREAK > nul
rem sleep 1
..\adb remount > nul

rem echo ------------------------------------
rem echo       	J1708 tx-rx test        
rem echo NOTE: Test MCU board has to be connected 
rem echo ------------------------------------
timeout /T 4 /NOBREAK > nul
rem sleep 2

:REPEAT_TEST

rem Enable j1708 power
rem TODO: currently there is an issue with this command
rem adb shell "mctl api 02fc01"
..\adb shell "mctl api 0213020001" > nul

rem Start process on device that cats the output of the ttyACM4 port and writes it to a file
..\adb shell "nohup cat /dev/ttyACM4 > /sdcard/j1708_device.log 2>/dev/null &"
timeout /T 3 /NOBREAK > nul
rem sleep 1

rem Send a j1708 message with msg id = 0x31, data = "j1708" (0x6a,0x31,0x37,0x30,0x38) and checksum = 95
..\adb shell "echo -ne '\x7e\x31\x6a\x31\x37\x30\x38\x95\x7e' > /dev/ttyACM4"

rem sometimes messages are not being received back, so requesting multiple times (not sure why - Abid)
timeout /T 1 /NOBREAK > nul
rem sleep 0.1
..\adb shell "echo -ne '\x7e\x31\x6a\x31\x37\x30\x38\x95\x7e' > /dev/ttyACM4"
timeout /T 1 /NOBREAK > nul
rem sleep 0.1
..\adb shell "echo -ne '\x7e\x31\x6a\x31\x37\x30\x38\x95\x7e' > /dev/ttyACM4"


rem echo waiting for data for 3 seconds
timeout /T 3 /NOBREAK > nul
rem sleep 3

..\adb pull /sdcard/j1708_device.log > nul

set /p j1708_data=<%j1708_file%

rem check that the log file has data
call :strlen size j1708_data
if %size% LSS 5 goto TEST_REPEAT_INIT

rem search for the chars 'j1708' in the file
IF "%j1708_data%"=="%j1708_data:j1708=%" (
	GOTO TEST_REPEAT_INIT
) ELSE (
	GOTO TEST_PASS
)

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

:TEST_REPEAT_INIT
	IF %failure_count% GTR 5 (
		GOTO TEST_FAIL
	)
	set /A failure_count+=1
	ECHO repeat test, failure count = %failure_count% 
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/j1708_device.log" > nul
	set j1708_data=
	GOTO REPEAT_TEST


:TEST_PASS
	ECHO ** J1708 tx-rx test - passed
	rem ECHO error level %errorlevel%
	@echo J1708 tx-rx test - passed  >> testResults\%result_file_name%.txt
	GOTO CLEANUP
	
:TEST_FAIL
	set ERRORLEVEL=1
	rem ECHO error level %errorlevel%
	ECHO ** J1708 tx-rx test - failed
	@echo J1708 tx-rx test - failed, j1708 data: %j1708_data% >> testResults\%result_file_name%.txt
	GOTO CLEANUP

:CLEANUP
	rem adb shell "mctl api 0213020000"
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/j1708_device.log" > nul
	del j1708_device.log
	set j1708_file=
	set failure_count=
	set j1708_data=
	GOTO EXIT
	
:EXIT
 

