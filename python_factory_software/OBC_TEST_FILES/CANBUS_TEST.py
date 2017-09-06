#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#       CANBUS Test
#**********************

def canTest():
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_CAN_RESULT'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	# Find index of return code and return data
	index = returnString.find('result=') + 7
	resultCode = returnString[index:index + 1]
	
	index = returnString.find('"')
	resultData = returnString[index:].strip()
	
	result = (resultCode, resultData)
	
	return result

def retryPrompt(dict):

	while True:
		choice = input(dict['CANRetryPrompt'])
	
		if choice.lower() == 'y':
			return True
		elif choice.lower() == 'n':
			return False
		else:
			print('Invalid option. Please select either [Y/N]')
		

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()
	continueTesting = True
	data = ()

	while continueTesting == True:
		data = canTest()
		if data[0] == '1':
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)

	
	if data[0] == '1':
		print(Fore.GREEN + '** CanBus', dict['TestPassDash'], data[1] + Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + ' ** CanBus', dict['TestFailDash'], data[1] + Style.RESET_ALL)
		resultBool = False
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('canbusTest', True)
		else:
			DBUtil.updateLastTestResult('canbusTest', False)

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
	
	