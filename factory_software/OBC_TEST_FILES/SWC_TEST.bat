@ECHO OFF
set ERRORLEVEL=0
setlocal enabledelayedexpansion
set swc_file=swc_device.log
set /A failure_count=1

..\adb root > nul
..\adb connect 192.168.43.1 > nul
..\adb wait-for-device > nul
sleep 1
..\adb remount > nul

echo ------------------------------------
echo       	SWC tx-rx test
echo NOTE: Test MCU board has to be connected        
echo ------------------------------------

sleep 2

:REPEAT_TEST

echo setup and data capture takes upto 10 seconds

rem Start process on device that cats the output of the ttyACM3 port and writes it to a file
..\adb shell "nohup cat /dev/ttyACM3 > /sdcard/swc_device.log 2>/dev/null &"
sleep 2

REM rem Setup SWC
rem sleep .1
..\adb shell "echo -ne 'Cu0001\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'mt000007FFu0002\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'Mt000007E8u0003\r' > /dev/ttyACM3"
rem sleep .1
..\adb shell "echo -ne 'S2u0004\r' > /dev/ttyACM3"
sleep 2
..\adb shell "echo -ne 'O1u0005\r' > /dev/ttyACM3"

sleep 3

rem Send SWC packet with a flow control byte0 = 10

..\adb shell "echo -ne 't7E08103456789abcdef0\r' > /dev/ttyACM3"
sleep 1
..\adb shell "echo -ne 't7E08103456789abcdef0\r' > /dev/ttyACM3"

sleep 1

..\adb pull /sdcard/swc_device.log > nul

rem get last line of file and then get the first 21 chars

for /F "delims=" %%i in (%swc_file%) do set "swc_data=%%i"

set swc_data=%swc_data:~0,21%

ECHO %swc_data%

IF "%swc_data%" == "t7e880102030405060708" (
	GOTO TEST_PASS
) ELSE (
	rem if no data captured from SWC, try again
	if %failure_count% GTR 5 (
		GOTO TEST_FAIL
	)
	set /A failure_count+=1
	ECHO repeat test, failure count = %failure_count%
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/swc_device.log" > nul
	GOTO REPEAT_TEST
)

:TEST_PASS
	ECHO SWC tx-rx test - passed
	@echo SWC tx-rx test - passed  >> testResults\%result_file_name%.txt
	GOTO CLEANUP
	
:TEST_FAIL
	set ERRORLEVEL=1
	ECHO SWC tx-rx test - failed
	@echo SWC tx-rx test - failed, %swc_data% >> testResults\%result_file_name%.txt
	GOTO CLEANUP

:CLEANUP
	..\adb shell "echo -ne 'Cu0001\r' > /dev/ttyACM3" > nul
	..\adb shell "busybox pkill cat" > nul
	..\adb shell "rm /sdcard/swc_device.log" > nul
	del swc_device.log
	set swc_file=
	set failure_count=
	set swc_data=
	GOTO EXIT
	
:EXIT
