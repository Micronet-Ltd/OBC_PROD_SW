@echo off

rem echo ------------------------------------
rem echo          INSTALLING FILES            
rem echo ------------------------------------

..\adb install -r INSTALL_FILES\nfc_test.apk >nul 2>&1
rem invoke the nfc test application 
..\adb shell "am start  -n 'me.davidvassallo.nfc/me.davidvassallo.nfc.MainActivity' -a android.intent.action.MAIN -c android.intent.category.LAUNCHER" >nul 2>&1
rem ..\adb push "INSTALL_FILES\MissionImpossible.mp3" /data/local/tmp/ >nul 2>&1
rem ..\adb push "INSTALL_FILES\track56.mp3" /data/local/tmp/ >nul 2>&1

rem Install application
..\adb install -r INSTALL_FILES\obc_testing_app.apk >nul 2>&1
rem Start main activity
..\adb shell "am start -n com.micronet.obctestingapp/com.micronet.obctestingapp.MainActivity" >nul 2>&1