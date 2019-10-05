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
if not defined language_file set language_file=input/languages/English.txt

rem echo ------------------------------------
rem echo             GPS test
rem echo ------------------------------------

echo.

rem Read in GPS Input data
for /f "tokens=1,2 delims=:" %%i in (%options_file%) do (
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

:_test
rem Send broadcast to receive gps test info
..\adb shell am broadcast -a com.micronet.obctestingapp.GET_GPS_RESULT --ei NumOfAverageSatellites %numOfSatellitesToIncludeInAverage% > %temp_file%

rem pause

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

echo Satellites: %satellites%
echo Satellites used in fix: %satellitesUsedInFix%
echo Time to first fix: %timeToFirstFix%
echo Average SNR used in fix: %averageSNRUsedInFix%
echo Average SNR of top %numOfSatellitesToIncludeInAverage% satellites used in fix: %averageSNROfTopSatellites%
echo.
rem pause

rem Check GPS values
rem if %satellitesUsedInFix% LSS %satellitesUsedInFixLowerBound% goto _test_fail
rem if %averageSNROfTopSatellites% LSS %averageSNROfTopSatellitesLowerBound% goto _test_fail
if %timeToFirstFix% GTR %timeToFirstFixLowerBound% goto _test_fail
if %satellitesUsedInFix% LSS %satellitesUsedInFixLowerBound% goto _test_fail
goto _test_pass

rem   ############## TEST STATUS ############
:_ask_if_retry
echo.
set /p option=GPS test failed, would you like to retry [Y/N]:
if /I "%option%"=="Y" goto _test
if /I "%option%"=="N" goto _test_fail
echo Invalid option
goto _ask_if_retry

:_test_fail
set ERRORLEVEL=1
set "xprvar="
for /F "skip=33 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0c "** "
echo GPS %xprvar%
@echo GPS test - fail >> testResults\%result_file_name%.txt
goto _end_of_file

:_test_pass
set "xprvar="
for /F "skip=34 delims=" %%i in (%language_file%) do if not defined xprvar set "xprvar=%%i"
call color.bat 0a "** "
echo GPS %xprvar%
@echo GPS test - passed >> testResults\%result_file_name%.txt

:_end_of_file
if exist %temp_file% del %temp_file%
set satellites=
set satellitesUsedInFix=
set timeToFirstFix=
set averageSNRUsedInFix=
set averageSNROfTopSatellites=
