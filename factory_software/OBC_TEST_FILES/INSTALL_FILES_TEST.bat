@echo off

rem echo ------------------------------------
rem echo          INSTALLING FILES            
rem echo ------------------------------------

..\adb install -r INSTALL_FILES\nfc_test.apk >nul 2>&1
..\adb install -r INSTALL_FILES\GetIMEI.apk 
rem invoke android test applications 
..\adb shell "am start  -n imeiviaadb.micronet.com.imeiviaadb/imeiviaadb.micronet.com.imeiviaadb.MainActivity"
..\adb shell "am start  -n 'me.davidvassallo.nfc/me.davidvassallo.nfc.MainActivity' -a android.intent.action.MAIN -c android.intent.category.LAUNCHER" >nul 2>&1
rem ..\adb push "INSTALL_FILES\MissionImpossible.mp3" /data/local/tmp/ >nul 2>&1
rem ..\adb push "INSTALL_FILES\track56.mp3" /data/local/tmp/ >nul 2>&1