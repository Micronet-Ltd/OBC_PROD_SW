#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#       Com Test
#**********************

def comTest():
	
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_COM_RESULT'
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
		choice = input(dict['ComRetryPrompt'])
	
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
		data = comTest()
		if data[0] == '1':
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)

	
	if data[0] == '1':
		print('Com Port', dict['TestPassDash'], data[1])
		resultBool = True
	else:
		print('Com Port', dict['TestFailDash'], data[1])
		resultBool = False
		
	if update:
		testResult = DBUtil.getLastInserted()
		if resultBool:
			testResult.comTest = True
		else:
			testResult.comTest = False
		
		print('Object has been updated from COM_TEST')
		DBUtil.commitSession()

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("COM Test is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil		
	
	