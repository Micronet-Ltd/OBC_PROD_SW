@echo off
set ERRORLEVEL=0

rem echo ------------------------------------
rem echo              SUPERCAP TEST            
rem echo ------------------------------------
set sc_voltage_file_name=sc_test.txt
set tmp_file_name=tmp.txt
rem --------- check supercap charging  ----------------
:_read_supercap_voltage_level
rem line structure is: GPI 9, approx voltage = VALUE mV, ret = -3
rem need to read only the VALUE and compare to expected range
..\adb shell mctl api 020409>%sc_voltage_file_name%
set /p sc_voltage=<%sc_voltage_file_name%
set /a sc_voltage=%sc_voltage:~24,5%
rem echo supercap voltage =  %sc_voltage%

rem verify supercap is charged but not over charged
if %sc_voltage% LSS 3000 goto _SC_LEVEL_ERROR
if %sc_voltage% GTR 5500 goto _SC_LEVEL_ERROR

rem --------- end check supercap charging  _-----------

rem --------- check deivces is off ---------------------
:_read_input_voltage_level
rem set the power loss output 
..\adb shell echo 991 ^> /sys/class/gpio/export

rem measure Input voltage - verify power is OFF
echo Turn Device OFF - press any key when ready ...
pause > nul

..\adb shell mctl api 020408>%sc_voltage_file_name%
rem line structure is: GPI 8, approx voltage = VALUE mV, ret = -3
rem need to read only the VALUE and compare to expected range
set /p power_in_voltage=<%sc_voltage_file_name%
set /a power_in_voltage=%power_in_voltage:~24,5%
rem echo power in voltage : %power_in_voltage%

rem verify input voltage is off
if %power_in_voltage% GTR 6000 goto _VIN_LEVEL_ERROR
rem --------- end check deivces is off --------------------

:_read_supercap_discharge
set /a loop_cnt = 0
:_SC_LOOP
rem echo | set /p=.
set /a loop_cnt = %loop_cnt% + 1
..\adb shell mctl api 020409 > %sc_voltage_file_name%
set /p sc_voltage_off=<%sc_voltage_file_name%
set /a sc_voltage_off=%sc_voltage_off:~24,5%
..\adb shell cat /sys/class/gpio/gpio991/value > %tmp_file_name%
set /p power_loss=<%tmp_file_name%
rem echo supercap discharging %sc_voltage_off%
rem echo %power_loss%

if %power_loss%==1 goto _test_pass 
if %loop_cnt%   GTR  100 goto _Power_loss_error
rem if %sc_voltage% GTE %sc_voltage_off% goto _DisCharge_ERROR ------------------this check cancled, in this time the voltage is much more then the voltage in the beringing 
goto _SC_LOOP

------------------this check cancled, in this time the voltage is much more then the voltage in the beringing
_check_discharge
rem if %sc_voltage% GTE %sc_voltage_off% goto _DisCharge_ERROR
rem goto _test_pass

rem   ############## TEST STATUS ############
:_SC_LEVEL_ERROR
set ERRORLEVEL=1
echo ** supercap test - failed (SC voltage = %sc_voltage%) 
@echo supercap test - failed (SC voltage = %sc_voltage%) >> testResults\%result_file_name%.txt
goto _end_of_test

:_VIN_LEVEL_ERROR
set ERRORLEVEL=1
echo ** supercap test - failed  Device NOT OFF (Input voltage = %power_in_voltage%) 
@echo supercap test - failed Device NOT OFF (Input voltage = %power_in_voltage%) >> testResults\%result_file_name%.txt
goto _end_of_test

:_DisCharge_ERROR
set ERRORLEVEL=1
echo ** supercap test - failed Device NOT OFF (Input voltage = %power_in_voltage%) 
@echo supercap test - failed Device NOT OFF (Input voltage = %power_in_voltage%) >> testResults\%result_file_name%.txt
goto _end_of_test

:_Power_loss_error
set ERRORLEVEL=1
echo ** supercap test - failed didn't get power loss notification 
@echo supercap test - failed didn't get power loss notification >> testResults\%result_file_name%.txt
goto _end_of_test

:_test_pass
echo ** supercap test - passed
@echo supercap test - passed supercap voltage : %sc_voltage%, voltage after off: %power_in_voltage% >> testResults\%result_file_name%.txt
:_end_of_test
if exist %sc_voltage_file_name% del %sc_voltage_file_name%
if exist %tmp_file_name%  del %tmp_file_name%
set sc_voltage_file_name=
set sc_voltage=
set device_status=
set loop_cnt=
set power_loss=
set power_in_voltage=
set sc_voltage_off=
