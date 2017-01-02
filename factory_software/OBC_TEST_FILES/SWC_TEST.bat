@ECHO OFF
set ERRORLEVEL=0
rem setlocal enabledelayedexpansion
set swc_file=swc_device.log
set /A failure_count=0

rem ..\adb root > nul
rem ..\adb connect 192.168.43.1 > nul
rem ..\adb wait-for-device > nul
rem timeout /T 1 /NOBREAK > nul
rem sleep 1
..\adb remount > nul

rem echo ------------------------------------
rem echo       	SWC tx-rx test
rem echo NOTE: Test MCU board has to be connected        
rem echo ------------------------------------

timeout /T 4 /NOBREAK > nul
rem sleep 2

:REPEAT_TEST

rem echo setup and data capture takes upto 10 seconds

rem Start process on device that cats the output of the ttyACM3 port and writes it to a file
..\adb shell "nohup cat /dev/ttyACM3 > /sdcard/swc_device.log 2>/dev/null &"
timeout /T 3 /NOBREAK > nul
rem sleep 2

REM rem Setup SWC
rem sleep .1
..\adb shell "echo -ne 'Cu0001\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'mt000007FFu0002\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'Mt000007E8u0003\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'S2u0004\r' > /dev/ttyACM3"
timeout /T 2 /NOBREAK > nul
rem sleep 2
..\adb shell "echo -ne 'O1u0005\r' > /dev/ttyACM3"
timeout /T 3 /NOBREAK > nul
rem sleep 3

rem Send SWC packet with a flow control byte0 = 10

..\adb shell "echo -ne 't7E08103456789abcdef0\r' > /dev/ttyACM3"
timeout /T 1 /NOBREAK > nul
rem sleep 1
..\adb shell "echo -ne 't7E08103456789abcdef0\r' > /dev/ttyACM3"
timeout /T 1 /NOBREAK > nul
rem sleep 1

..\adb pull /sdcard/swc_device.log 2>&1>nul


set /p swc_data=<%swc_file%

rem check that the log file has data
call :strlen size swc_data
if %size% LSS 21 goto TEST_REPEAT_INIT

rem search for the chars 't7e880102030405060708' in the file
rem IF "%swc_data%"=="%swc_data:t7e880102030405060708=%" (
findstr /m t7e880102030405060708 %swc_file% > tmp.txt
set found="Not Found"
set /p found= < tmp.txt
rem if the the string 't7e880102030405060708' exists the the findster will return the file name
rem echo  found = %found%
if %found% NEQ swc_device.log (
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
	rem if no data captured from SWC, try again
	if %failure_count% GTR 5 (
		GOTO TEST_FAIL
	)
	set /A failure_count+=1
	ECHO repeat test, failure count = %failure_count%
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/swc_device.log" > nul
	set swc_data=
	GOTO REPEAT_TEST

:TEST_PASS
	ECHO ** SWC tx-rx test - passed
	@echo SWC tx-rx test - passed  >> testResults\%result_file_name%.txt
	GOTO CLEANUP
	
:TEST_FAIL
	set ERRORLEVEL=1
	ECHO ** SWC tx-rx test - failed
	ECHO error level %ERRORLEVEL%
	@echo SWC tx-rx test - failed, %swc_data% >> testResults\%result_file_name%.txt
	GOTO CLEANUP

:CLEANUP
	..\adb shell "echo -ne 'Cu0001\r' > /dev/ttyACM3" > nul
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/swc_device.log" > nul
	del swc_device.log
	if exist tmp.txt del tmp.txt
	set swc_file=
	set failure_count=
	set swc_data=
	set found=
	endlocal
	GOTO EXIT
	
:EXIT
