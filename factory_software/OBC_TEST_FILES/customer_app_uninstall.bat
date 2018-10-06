@echo off
@echo.

SET "tempDir=tempDirectory"
SET "tempFileName1=temp_uninstall.txt"
SET "tempFileName2=temp_count.txt"
SET "tempFileName3=temp_count_final.txt"
SET "defaultSystemApp=com.inthinc.inthinccontrol"

rem @echo ***********************************************************************************************
rem @echo ******************************* Cleaning Device [APKs, Files] *********************************
rem @echo ***********************************************************************************************

@echo.
@echo.
@echo Cleaning device, removing apks and critical files

@echo.

@echo.&set /P "packageName=  Enter package name string and hit enter:"

@echo.
@echo.
@echo Verify what customer applications are installed?
@echo ------------------------------------------------------------------------------------------------
rem Get the list of packages installed with a specific name
..\adb shell pm list packages | find "%packageName%" > %tempFileName1%

rem Print all the packages identified with the same package name
for /F "tokens=2* delims=:" %%G in (temp_uninstall.txt) do echo Packages Installed: %%G
@echo ------------------------------------------------------------------------------------------------

@echo.
@echo.

@echo How many packages are installed?
 rem Print the number of packages installed
 ..\adb shell pm list packages | find "%packageName%" | find "" /v /c > %tempFileName2%
 set /p count=<%tempFileName2%
 set /a count=%count%

@echo ------------------------------------------------------------------------------------------------
@echo Number of Customer Apps installed = %count%
@echo ------------------------------------------------------------------------------------------------

@echo.
@echo.
@echo Begin Uninstalling Applications

rem Running a for loop on the contents of the file temp_uninstall.txt
setlocal enableDelayedExpansion
set /A systemAppCount=0
for /F "tokens=2* delims=:" %%G in (temp_uninstall.txt) do (
	@echo.
  set package=%%G
  set package=!package:~0,-1!
	@echo Package:!package!
	if /I "!package!" == "com.inthinc.inthinccontrol" (
		set /A systemAppCount=!systemAppCount!+1
		@echo Message: Not allowed to uninstall a system app %%G
		)
	if /I NOT "!package!"=="%defaultSystemApp%" (
		..\adb uninstall !package!
		)
)
echo Number of System Apps that cannot be uninstalled %systemAppCount%
..\adb shell pm list packages | find "%packageName%" | find "" /v /c > %tempFileName3%
set /p countFinal=<%tempFileName3%
set /a countFinal=%countFinal%
if %systemAppCount% EQU %countFinal% (

@echo.
rem Removing Temp Files
del %tempFileName1% /s /f /q > nul 2>&1
del %tempFileName2% /s /f /q > nul 2>&1
del %tempFileName3% /s /f /q > nul 2>&1
@echo.
rem @echo ***********************************************************************************************
rem @echo **************************************** TEST PASSED ******************************************
rem @echo ***********************************************************************************************
rem @echo.
set pass=pass
)

if NOT %systemAppCount% EQU %countFinal%  (
@echo.
@echo.
@echo ** Error Uninstalling Customer Apps
@echo Error Uninstalling Customer Apps >> testResults\%result_file_name%.txt
rem @echo ***********************************************************************************************
rem @echo **************************************** TEST FAILED ******************************************
rem @echo ***********************************************************************************************
rem @echo.
set pass=fail
)

echo %pass% > res.txt
endlocal
