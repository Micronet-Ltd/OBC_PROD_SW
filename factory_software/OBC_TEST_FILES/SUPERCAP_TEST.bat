@echo off
set ERRORLEVEL=0

rem echo ------------------------------------
rem echo              SUPERCAP TEST            
rem echo ------------------------------------
set sc_voltage_file_name=sc_test.txt
set tmp_file_name=tmp.txt

rem Change the default of wi-fi off during power loss
..\adb shell "chmod 666 /sys/class/hwmon/hwmon1/wlan_off_delay"  
..\adb shell "echo 17000 > /sys/class/hwmon/hwmon1/wlan_off_delay" 

rem --------- check supercap charging  ----------------
:_read_supercap_voltage_level
rem line structure is: GPI 9, approx voltage = VALUE mV, ret = 4
rem need to read only the VALUE and compare to expected range
..\adb shell mctl api 020409>%sc_voltage_file_name%
set /p sc_voltage=<%sc_voltage_file_name% > nul 2>&1
set /a sc_voltage=%sc_voltage:~24,5% > nul 2>&1
rem echo supercap voltage =  %sc_voltage%

rem verify supercap is charged but not over charged
if %sc_voltage% LSS 3000 goto _SC_LEVEL_ERROR
if %sc_voltage% GTR 5500 goto _SC_LEVEL_ERROR

rem --------- end check supercap charging  -----------

rem --------- check deivces is off ---------------------
:_read_input_voltage_level
rem Export the power loss output 
..\adb shell echo 991 ^> /sys/class/gpio/export

rem Read initial input power voltage
..\adb shell mctl api 020408>%sc_voltage_file_name%
rem line structure is: GPI 8, approx voltage = VALUE mV, ret = 4
rem need to read only the VALUE and compare to expected range
set /p power_in_voltage_on=<%sc_voltage_file_name% >nul 2>&1
set /a power_in_voltage_on=%power_in_voltage_on:~24,5% >nul 2>&1
rem echo power in voltage ON state: %power_in_voltage_on%

rem measure Input voltage - verify power is OFF
echo.
echo Turn Device OFF - press any key when power is removed ...
pause > nul

rem 2 sec delay added after the device is switched off incase the user presses any key before disconnecting power
rem It also takes 2 seconds of power loss before the power loss GPIO is toggled by the MCU
timeout /T 2 /NOBREAK > nul

rem Read input power voltage after power is removed (running on supercap)
..\adb shell mctl api 020408 2>nul rem >%sc_voltage_file_name%
rem line structure is: GPI 8, approx voltage = VALUE mV, ret = 4
rem need to read only the VALUE and compare to expected range
set /p power_in_voltage_off=<%sc_voltage_file_name% >nul 2>&1
set /a power_in_voltage_off=%power_in_voltage_off:~24,5% >nul 2>&1
rem echo      power in voltage Supercap State: %power_in_voltage_off%

rem verify input voltage is off
if %power_in_voltage_off% GTR 8000 goto _VIN_LEVEL_ERROR
rem --------- end check device is off --------------------

:_read_supercap_discharge
set /a loop_cnt = 0
:_SC_LOOP
rem echo | set /p=.
set /a loop_cnt = %loop_cnt% + 1 >nul 2>&1
..\adb shell mctl api 020409 > %sc_voltage_file_name% 2>nul
set /p sc_voltage_off=<%sc_voltage_file_name% >nul 2>&1
set /a sc_voltage_off=%sc_voltage_off:~24,5% >nul 2>&1
..\adb shell cat /sys/class/gpio/gpio991/value > %tmp_file_name% 2>nul
set /p power_loss=<%tmp_file_name% >nul 2>&1
rem echo supercap discharging %sc_voltage_off%
rem echo %power_loss%

if [%power_loss%] EQU [1] goto _test_pass 
if %loop_cnt%   GTR  50 goto _Power_loss_error
rem if %sc_voltage% GTE %sc_voltage_off% goto _DisCharge_ERROR ------------------this check cancled, in this time the voltage is much more then the voltage in the beringing 
goto _SC_LOOP

rem ------------------this check cancled, in this time the voltage is much more then the voltage in the beringing
rem _check_discharge
rem if %sc_voltage% GTE %sc_voltage_off% goto _DisCharge_ERROR
rem goto _test_pass

rem   ############## TEST STATUS ############
:_SC_LEVEL_ERROR
set ERRORLEVEL=1
echo ** Supercap test - failed initial SuperCap voltage not in range - _SC_LEVEL_ERROR
@echo Supercap test - failed initial SuperCap voltage not in range (SC voltage = %sc_voltage%) - _SC_LEVEL_ERROR >> testResults\%result_file_name%.txt
goto _read_input_voltage_level

:_VIN_LEVEL_ERROR
set ERRORLEVEL=1
echo ** Supercap test - failed Input voltage too high in supercap mode - _VIN_LEVEL_ERROR
@echo Supercap test - failed Input voltage too high in supercap mode (Input voltage ON state = %power_in_voltage_on%, Input voltage SC state = %power_in_voltage_off%) - _VIN_LEVEL_ERROR >> testResults\%result_file_name%.txt
goto _read_supercap_discharge

:_DisCharge_ERROR
set ERRORLEVEL=1
echo ** Supercap test - failed Supercap did not discharge - _DisCharge_ERROR
@echo Supercap test - failed Supercap did not discharge (SC voltage = %sc_voltage%, SC off voltage = %sc_voltage_off%, Input voltage ON state = %power_in_voltage_on%, Input voltage SC state = %power_in_voltage_off%) - _DisCharge_ERROR >> testResults\%result_file_name%.txt
goto _end_of_test

:_Power_loss_error
set ERRORLEVEL=1

echo ** Supercap test - failed didn't get power loss notification - _Power_loss_error
@echo Supercap test - failed didn't get power loss notification (SC voltage = %sc_voltage%, SC off voltage = %sc_voltage_off%, Input voltage ON state = %power_in_voltage_on%, Input voltage SC state= %power_in_voltage_off%) - _Power_loss_error >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_pass
echo ** Supercap test - passed
@echo Supercap test - passed supercap voltage : %sc_voltage%, SC off voltage = %sc_voltage_off%, Input voltage ON state = %power_in_voltage_on%, Input voltage SC state: %power_in_voltage_off% >> testResults\%result_file_name%.txt

:_end_of_test
echo                    supercap voltage : %sc_voltage%, 
echo                    SC off voltage = %sc_voltage_off%, 
echo                    Input voltage ON state = %power_in_voltage_on%, 
echo                    Input voltage SC state: %power_in_voltage_off%
if exist %sc_voltage_file_name% del %sc_voltage_file_name%
if exist %tmp_file_name%  del %tmp_file_name%
set sc_voltage_file_name=
set sc_voltage=
set device_status=
set loop_cnt=
set power_loss=
set power_in_voltage_on=
set power_in_voltage_off=
set sc_voltage_off=
