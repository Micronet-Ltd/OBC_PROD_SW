#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#     Wiggle Test
#**********************

def wiggleTest():
	count = 0
	
	print('Wiggle Test - Tap the device')
	
	# Open wiggle 
	cmd = '../adb.exe shell mctl api 021501'
	s = subprocess.check_output(cmd.split())
	
	returnBool = False
	
	for i in range(125):
		# Sample wiggle
		cmd = '../adb.exe shell mctl api 0216'
		s = subprocess.check_output(cmd.split())
		wiggleCount = s.decode("ascii")
		
		index = wiggleCount.find('count:') + 8
		endIndex = wiggleCount.find(',')
		
		wiggleCount = wiggleCount[index:endIndex]
		wiggleCount = int(wiggleCount)
		
		if wiggleCount > 1 and wiggleCount < 5000:
			# Close wiggle 
			cmd = '../adb.exe shell mctl api 021500'
			s = subprocess.check_output(cmd.split())
			return ('1',wiggleCount)
	

	# Close wiggle 
	cmd = '../adb.exe shell mctl api 021500'
	s = subprocess.check_output(cmd.split())
	return ('0',wiggleCount)
	
def retryPrompt(dict):

	while True:
		inputStr = 'Wiggle ' + dict['TestFail'] + '. ' + dict['RetryPrompt']
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
		data = wiggleTest()
		if data[0] == '1':
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	if data[0] == '1':
		print(Fore.GREEN + '** Wiggle', dict['TestPassDash'], 'count =', data[1], Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + ' ** Wiggle', dict['TestFailDash'], 'count =', data[1], Style.RESET_ALL)
		resultBool = False
	
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('wiggleTest', True)
		else:
			DBUtil.updateLastTestResult('wiggleTest', False)

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