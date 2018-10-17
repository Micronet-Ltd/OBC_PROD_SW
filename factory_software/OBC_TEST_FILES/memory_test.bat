@echo off
set ERRORLEVEL=0

rem -----------------------------------------------------------------------------------------------------------------------------
rem 										MEMORY_TEST
REM To get ROM:
REM ROM = 1 + ((cat /sys/class/block/mmcblk0/size * 512)/(1,000,000 *1024)) = 1 + ((15269888 * 512)/ (1,000,000 * 1024)) = 8.635 

REM RAM:
REM cat proc/meminfo
REM mem_total = 902344 kB
REM mapped = 181393 kB

REM RAM = (MemTotal + Mapped)/(1,000 * 1024) = (902344 + 181393)/(1000 * 1024) = 1.0582
rem -----------------------------------------------------------------------------------------------------------------------------

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.dat
if not defined options_file set options_file=input/test_options.dat

set loop_count=0
set temp_result=tmp.txt
set mem_total=
set mem_mapped=
if exist %temp_result% del %temp_result%

rem Set default values for ram/rom
set /a expected_rom=8
set /a expected_ram=1

rem Read in values from test options file
for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
	if /i "%%i" == "ROM" set /a expected_rom=%%j
	if /i "%%i" == "RAM" set /a expected_ram=%%j
)

rem get ROM size
..\adb shell cat /sys/class/block/mmcblk0/size > %temp_result%
set /p mmcblk0=<tmp.txt
rem echo mmcblk0= %mmcblk0%
rem done in multiple steps because batch can only do 32 bit math
set /a rom_size = %mmcblk0% /(1000 * 1024)
set /a rom_size = 1 + ((%rom_size%) * 512/1000)
rem echo ROM size = %rom_size% GB

rem get RAM size
rem get mem_total
..\adb shell "cat /proc/meminfo | grep MemTotal" > %temp_result%
for /F "tokens=2" %%G in (%temp_result%) do set /a mem_total=%%G
rem echo mem_total %mem_total%

rem get mapped
..\adb shell "cat /proc/meminfo | grep Mapped" > %temp_result%
for /F "tokens=2" %%G in (%temp_result%) do set /a mem_mapped=%%G
rem echo mem_mapped %mem_mapped%

set /a ram_size=(%mem_total% + %mem_mapped%)/(1000 * 1024)
rem echo RAM size = %ram_size% GB

if %rom_size% EQU %expected_rom% (
	if %ram_size% EQU %expected_ram% (
		goto _test_pass
	)
)

:test_fail
set ERRORLEVEL=1
call color.bat 0c "** "
echo Memory test - failed ROM = %rom_size% GB and RAM = %ram_size% GB
@echo Memory test - passed ROM = %rom_size% GB and RAM = %ram_size% GB >> testResults\%result_file_name%.txt
goto :_end_of_file


:_test_pass
set "xprvar="
call color.bat 0a "** "
echo Memory test - passed ROM = %rom_size% GB and RAM = %ram_size% GB
@echo Memory test - passed ROM = %rom_size% GB and RAM = %ram_size% GB >> testResults\%result_file_name%.txt
goto _end_of_file


:_end_of_file
rem call update_last_result.bat cell_asu "%asuValue%"
if exist %temp_result% del %temp_result%
set temp_result=
set mem_total=
set mem_mapped=

