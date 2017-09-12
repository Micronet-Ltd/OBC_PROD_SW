#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#       J1708 Test
#**********************

def j1708Test():

	# Enable J1708 power
	cmd = '../adb.exe shell mctl api 0213020001'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_J1708_RESULT'
	s = subprocess.check_output(cmd.split())
	try:
		returnString = s.decode("ascii")
	except UnicodeDecodeError:
		return (-1, "Code not parse return string.")

	# Find index of return code and return data
	index = returnString.find('result=') + 7
	resultCode = returnString[index:index + 1]
	
	index = returnString.find('data=') + 6
	resultData = returnString[index:].strip()
	
	resultData = resultData[:-1]
	
	result = (resultCode, resultData)
	
	return result

def retryPrompt(dict):

	while True:
		choice = input(dict['J1708RetryPrompt'])
	
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
		data = j1708Test()
		if data[0] == '1':
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	if data[0] == '1':
		print(Fore.GREEN + '** J1708', dict['TestPassDash'], data[1] + Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + ' ** J1708', dict['TestFailDash'], data[1] + Style.RESET_ALL)
		resultBool = False
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('j1708Test', True)
		else:
			DBUtil.updateLastTestResult('j1708Test', False)

# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	import colorama
	colorama.init()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil		
	
	