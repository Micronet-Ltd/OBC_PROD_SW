#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#       J1708 Test
#**********************

def j1708Test():
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_J1708_RESULT'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	# Find index of return code and return data
	index = returnString.find('result=') + 7
	resultCode = returnString[index:index + 1]
	
	index = returnString.find('"')
	resultData = returnString[index:]
	
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
		print('J1708', dict['TestPassDash'], data[1])
		resultBool = True
	else:
		print('J1708', dict['TestFailDash'], data[1])
		resultBool = False
		
	if update:
		testResult = DBUtil.getLastInserted()
		if resultBool:
			testResult.j1708Test = True
		else:
			testResult.j1708Test = False
		
		print('Object has been updated from J1708_TEST')
		DBUtil.commitSession()

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("J1708 Test is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil		
	
	