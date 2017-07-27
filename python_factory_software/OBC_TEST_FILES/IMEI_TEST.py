#!/usr/bin/python
import sys
import string
import os
import subprocess
import OBC_TEST_FILES.TestUtil

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

def Main(dict, session=None, index=None):


	print('\n')

	# Prompt user to scan IMEI
	scannedIMEI = input(dict['ScanIMEI'])

	deviceIMEI = getIMEI()

	matchingDevice = False
	correctTac = False

	if scannedIMEI == deviceIMEI:
		matchingDevice = True
	if deviceIMEI[0:8] == '35483308':
		correctTac = True
		
	if matchingDevice and scannedIMEI:
		print(dict['IMEIPass'].format(deviceIMEI))
	elif matchingDevice:
		print(dict['IMEIFail'].format(deviceIMEI, scannedIMEI), ': matching device but IMEI should start with \'35483308\'')
	elif correctTac:
		print(dict['IMEIFail'].format(deviceIMEI, scannedIMEI))
	else:
		print(dict['IMEIFail'].format(deviceIMEI, scannedIMEI), ': incorrect label and IMEI should start with \'35483308\'')
	
	
# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("IMEI Test is being called directly")
	langDict = TestUtil.getLanguageDict()
	Main(langDict)


