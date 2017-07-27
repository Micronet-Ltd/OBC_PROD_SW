#!/usr/bin/python
import sys
import string
import os
import subprocess
import time

#**********************
#    Install Files
#**********************

def Main():

	cmd = '..\adb install -r INSTALL_FILES\obc_testing_app.apk'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	print(returnString)
	
	cmd = '..\adb shell "am start -n com.micronet.obctestingapp/com.micronet.obctestingapp.MainActivity"'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	print(returnString)
	
	cmd = '..\adb install -r INSTALL_FILES\nfc_test.apk'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	print(returnString)
	
	cmd = '..\adb shell "am start  -n \'me.davidvassallo.nfc/me.davidvassallo.nfc.MainActivity\' -a android.intent.action.MAIN -c android.intent.category.LAUNCHER"'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	print(returnString)
	
	time.sleep(3)
	
	