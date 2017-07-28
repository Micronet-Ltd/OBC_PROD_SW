#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#     Help Key Test
#**********************

def hkTest(dict):
	
	count = 0
	
	cmd = '../adb.exe shell echo 1014 > /sys/class/gpio/export'
	s = subprocess.check_output(cmd.split())
	
	cmd = '../adb.exe shell cat /sys/class/gpio/gpio1014/value'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	if returnString.strip() != '1':
		return False
	
	print(dict['HKPrompt'])
	
	helpKeyPressedBool = False
	
	for i in range(75):
		cmd = '../adb.exe shell cat /sys/class/gpio/gpio1014/value'
		s = subprocess.check_output(cmd.split())
		returnString = s.decode("ascii")
		
		if returnString.strip() == '0':
			# HK pressed
			helpKeyPressedBool = True
			break

	# Button press was never detected
	if not helpKeyPressedBool:
		return False

	count = 0
	helpKeyReleasedBool = False
	
	for i in range(75):
		cmd = '../adb.exe shell cat /sys/class/gpio/gpio1014/value'
		s = subprocess.check_output(cmd.split())
		returnString = s.decode("ascii")
		
		if returnString.strip() == '1':
			# HK pressed
			helpKeyReleasedBool = True
			break
	
	# If release was detected then return true, else false
	if helpKeyReleasedBool:
		return True
	else:
		return False
	
def retryPrompt(dict):

	while True:
		inputStr = 'Help Key ' + dict['TestFail'] + '. ' + dict['RetryPrompt']
		choice = input(inputStr)
	
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

	while continueTesting:
		resultBool = hkTest(dict)
		if resultBool:
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	if resultBool:
		print(dict['HKPass'])
	else:
		print(dict['HKFail'])
		
		
	if update:
		testResult = DBUtil.getLastInserted()
		if resultBool:
			testResult.helpKeyTest = True
		else:
			testResult.helpKeyTest = False
		
		print('Object has been updated from HELP_KEY_TEST')
		DBUtil.commitSession()

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("Help Key Test is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	