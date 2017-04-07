@echo off

:_start_test
set ERRORLEVEL=0

set file_name=tmp.txt
if exist %file_name% del %file_name%

rem echo ------------------------------------
rem echo                GPIO Test            
rem echo ------------------------------------


:_test_GPIO1
..\adb shell mctl api 020401 > %file_name%
set /p input1=<%file_name%
set /a input1=%input1:~24,5%
rem @echo input1=%input1%
if %input1% LSS 7000 set ERRORLEVEL=1
if %input1% GTR  13100 set ERRORLEVEL=1

:_test_GPIO2
..\adb shell mctl api 020402 > %file_name%
set /p  input2=<%file_name%
set /a input2=%input2:~24,5%>nul
rem @echo input2=%input2%
if %input2% LSS 4500 set ERRORLEVEL=1
if %input2% GTR 5500 set ERRORLEVEL=1

:_test_GPIO3
..\adb shell mctl api 020403 > %file_name%
set /p  input3=<%file_name%
set /a input3=%input3:~24,5%>nul
rem @echo input3=%input3%
if %input3% LSS 7000 set ERRORLEVEL=1
if %input3% GTR  13100 set ERRORLEVEL=1

:_test_GPIO4
..\adb shell mctl api 020404 > %file_name%
set /p  input4=<%file_name%
set /a input4=%input4:~24,5%>nul
rem @echo input4=%input4%
if %input4% LSS 4500 set ERRORLEVEL=1
if %input4% GTR 5500 set ERRORLEVEL=1

:_test_GPIO5
..\adb shell mctl api 020405 > %file_name%
set /p  input5=<%file_name%
set /a input5=%input5:~24,5%>nul
rem @echo input5=%input5%
if %input5% LSS 7000 set ERRORLEVEL=1
if %input5% GTR  13100 set ERRORLEVEL=1


:_test_GPIO6
..\adb shell mctl api 020406 > %file_name%
set /p  input6=<%file_name%
set /a input6=%input6:~24,5%>nul
rem @echo input6=%input6%
if %input6% LSS 4500 set ERRORLEVEL=1
if %input6% GTR 5500 set ERRORLEVEL=1

:_test_GPIO7
..\adb shell mctl api 020407 > %file_name%
set /p  input7=<%file_name%
set /a input7=%input7:~24,5%>nul
rem @echo input7=%input7%
if %input7% LSS 7000 set ERRORLEVEL=1
if %input7% GTR  13100 set ERRORLEVEL=1

:_test_Ignition
..\adb shell mctl api 020400 > %file_name%
set /p  Ignition=<%file_name%
set /a Ignition=%Ignition:~24,5%>nul
rem @echo Ignition=%Ignition%
if %Ignition% LSS 4500 set ERRORLEVEL=1
if %Ignition% GTR 13200 set ERRORLEVEL=1

if %ERRORLEVEL% == 1 goto _error_found

echo ** GPIO test - passed
@echo GPIO test - pased input1=%input1%, input2=%input2%, input3=%input3%, input4=%input4%, input5=%input5%, input6=%input6%, input7=%input7%, Ignition=%Ignition%  >> testResults\%result_file_name%.txt
goto _end_of_file

:_error_found
echo.
echo ** GPIO test - failed input1=%input1%, input2=%input2%, input3=%input3%, input4=%input4%, input5=%input5%, input6=%input6%, input7=%input7%, Ignition=%Ignition%
@echo GPIO test - failed input1 = %input1%, input2=%input2%, input3=%input3%, input4=%input4%, input5=%input5%, input6=%input6%, input7=%input7%, Ignition=%Ignition% >> testResults\%result_file_name%.txt

set choice=
echo.&set /p choice=Would you like to repeat the test [Y/N] ?
if /I %choice% == Y goto _start_test

:_end_of_file
if exist %file_name% del %file_name%
set file_name= 
set input1= 
set input2= 
set input3= 
set input4= 
set input5= 
set input6= 
set input7= 
set Ignition=
set choice=