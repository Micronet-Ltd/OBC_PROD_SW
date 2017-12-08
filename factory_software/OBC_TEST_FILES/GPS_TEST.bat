@echo off

set ERRORLEVEL=0

set satellitesUsedInFixLowerBound=
set averageSNROfTopSatellitesLowerBound=
set numOfSatellitesToIncludeInAverage=
set numberOfTestRetries=
set timeToFirstFixLowerBound=

set temp_file=tmp.txt
if exist %temp_file% del %temp_file%

rem If language file is not set then default to english
if not defined language_file set language_file=input/English.txt

rem echo ------------------------------------
rem echo             GPS test                
rem echo ------------------------------------

rem Read in GPS Input data
for /f "tokens=1,2 delims=:" %%i in (input\GPS_INPUT.dat) do (
 if "%%i" == "SatellitesUsedInFixLowerBound" set /A satellitesUsedInFixLowerBound=%%j
 if "%%i" == "AverageSNROfTopSatellitesLowerBound" set /A averageSNROfTopSatellitesLowerBound=%%j
 if "%%i" == "NumberOfSatellitesToIncludeInTopAverage" set /A numOfSatellitesToIncludeInAverage=%%j
 if "%%i" == "NumberOfTestRetries" set /A numberOfTestRetries=%%j
 if "%%i" == "TimeToFirstFix" set /A timeToFirstFixLowerBound=%%j
)

rem echo %satellitesUsedInFixLowerBound%
rem echo %averageSNROfTopSatellitesLowerBound%
rem echo %numOfSatellitesToIncludeInAverage%
rem echo %numberOfTestRetries%
rem echo %timeToFirstFixLowerBound%

rem pause

:_test_loop
rem Send broadcast to receive gps test info
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_GPS_RESULT --ei NumOfAverageSatellites %numOfSatellitesToIncludeInAverage% > %temp_file%

rem Parse second line of result on double quotes to get gps test info.
set "xprvar="
for /F delims^=^"^ tokens^=2^ skip^=1 %%i in (tmp.txt) do if not defined xprvar set "xprvar=%%i"

if exist %temp_file% del %temp_file%

rem echo %xprvar%

echo %xprvar% > %temp_file%

rem pause

set satellites=
set satellitesUsedInFix=
set timeToFirstFix=
set averageSNRUsedInFix=
set averageSNROfTopSatellites=

for /F "delims=,: tokens=2,4,6,8,10" %%i in (tmp.txt) do (
 set /A satellites=%%i
 set /A satellitesUsedInFix=%%j
 set /A timeToFirstFix=%%k
 set /A averageSNRUsedInFix=%%l >nul 2>&1
 set /A averageSNROfTopSatellites=%%m >nul 2>&1
)

rem echo Satellites: %satellites%
rem echo Satellites used in fix: %satellitesUsedInFix%
rem echo Time to first fix: %timeToFirstFix%
rem echo Average SNR used in fix: %averageSNRUsedInFix%
rem echo Average SNR of top %numOfSatellitesToIncludeInAverage% satellites used in fix: %averageSNROfTopSatellites%

rem pause

rem Check GPS values
if %satellitesUsedInFix% LSS %satellitesUsedInFixLowerBound% goto _ask_if_retry
if %averageSNROfTopSatellites% LSS %averageSNROfTopSatellitesLowerBound% goto _ask_if_retry
goto _test_pass

:_ask_if_retry
set "xprvar="
for /F "skip=10 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
set "xprvar2="
for /F "skip=31 delims=" %%i in (%language_file%) do if not defined xprvar2 set "xprvar2=%%i"
echo.&set /p option=GPS %xprvar2%. %xprvar%
if /I "%option%"=="Y" goto _test_loop
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

rem   ############## TEST STATUS ############
:_test_fail
set ERRORLEVEL=1

set satellitesInFixString=
set averageSNROfTopSatellitesString=
if %satellitesUsedInFix% LSS %satellitesUsedInFixLowerBound% set satellitesInFixString=Saw %satellitesUsedInFix% satellites used in fix but needed %satellitesUsedInFixLowerBound%,
if %averageSNROfTopSatellites% LSS %averageSNROfTopSatellitesLowerBound% set averageSNROfTopSatellitesString=Average SNR not high enough: got %averageSNROfTopSatellites% but needed %averageSNROfTopSatellitesLowerBound%

set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** GPS %xprvar% %satellitesInFixString% %averageSNROfTopSatellitesString%
@echo GPS test - fail %satellitesInFixString% %averageSNROfTopSatellitesString% >> testResults\%result_file_name%.txt
<nul set /p ".=%averageSNROfTopSatellites%," >> %summaryFile%
<nul set /p ".=%satellitesUsedInFix%," >> %summaryFile%
goto _end_of_file

:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
echo ** GPS %xprvar% : Average SNR: %averageSNROfTopSatellites%, Satellites used in fix: %satellitesUsedInFix%
@echo GPS test - passed : Average SNR: %averageSNROfTopSatellites%, Satellites used in fix: %satellitesUsedInFix% >> testResults\%result_file_name%.txt
<nul set /p ".=%averageSNROfTopSatellites%," >> %summaryFile%
<nul set /p ".=%satellitesUsedInFix%," >> %summaryFile%

:_end_of_file
if exist %temp_file% del %temp_file%
set satellites=
set satellitesUsedInFix=
set timeToFirstFix=
set averageSNRUsedInFix=
set averageSNROfTopSatellites=