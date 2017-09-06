#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#      IMEI Test
#**********************

def getIMEI():
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_IMEI'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	# Find index of return data and get IMEI
	IMEIIndex = returnString.find('data=') + 6
	
	IMEI = returnString[IMEIIndex:IMEIIndex+15]
	
	return IMEI

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()

	# Prompt user to scan IMEI
	scannedIMEI = input(dict['ScanIMEI'])

	deviceIMEI = getIMEI()

	matchingDevice = False
	correctTac = False

	if scannedIMEI == deviceIMEI:
		matchingDevice = True
	if deviceIMEI[0:8] == '35483308':
		correctTac = True
		
	resultBool = False
		
	if matchingDevice and scannedIMEI:
		print(Fore.GREEN + dict['IMEIPass'].format(deviceIMEI) + Style.RESET_ALL)
		resultBool = True
	elif matchingDevice:
		print(Fore.RED + dict['IMEIFail'].format(deviceIMEI, scannedIMEI), ': matching device but IMEI should start with \'35483308\'' + Style.RESET_ALL)
	elif correctTac:
		print(Fore.RED + dict['IMEIFail'].format(deviceIMEI, scannedIMEI) + Style.RESET_ALL)
	else:
		print(Fore.RED + dict['IMEIFail'].format(deviceIMEI, scannedIMEI), ': incorrect label and IMEI should start with \'35483308\'' + Style.RESET_ALL)

	if update:
		DBUtil.updateLastTestResult('imei', deviceIMEI)
		if resultBool:
			DBUtil.updateLastTestResult('imeiTest', True)
		else:
			DBUtil.updateLastTestResult('imeiTest', False)
			
# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	import colorama
	colorama.init()
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil


