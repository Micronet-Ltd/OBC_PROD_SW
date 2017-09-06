#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#     Serial Test
#**********************

def getSerialNumber():
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_SERIAL'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	# Find index of return data and get serial number
	serialIndex = returnString.find('data=') + 6
	
	serialNumber = 'PM' + returnString[serialIndex:serialIndex+8]
	
	return serialNumber

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()

	# Prompt user to scan serial number
	scannedSerial = input(dict['ScanSN'])

	deviceSerialNumber = getSerialNumber()

	if scannedSerial == deviceSerialNumber:
		print(Fore.GREEN + dict['SNPass'].format(deviceSerialNumber) + Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + dict['SNFail'].format(deviceSerialNumber, scannedSerial) + Style.RESET_ALL)
		resultBool = False

	if update == True:
		DBUtil.updateLastTestResult('serial', deviceSerialNumber[2:]) 
		if resultBool:
			DBUtil.updateLastTestResult('serialTest', True)
		else:
			DBUtil.updateLastTestResult('serialTest', False)
		
		
	
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
	