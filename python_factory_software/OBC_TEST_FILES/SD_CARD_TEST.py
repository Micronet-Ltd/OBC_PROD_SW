#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#     SD Card Test
#**********************

def sdCardTest(dict):
	
	cmd = '../adb.exe shell ls ./storage/sdcard1/'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	if 'opendir failed' in returnString:
		return False
		
	# Copy file to SD Card
	try:
		with open(os.devnull, 'w') as nul:
			cmd = '../adb.exe push .\INSTALL_FILES\sd-card_test.txt ./storage/sdcard1/'
			s = subprocess.check_output(cmd.split(), stderr=nul)
	except subprocess.CalledProcessError:
		# This happens when no sd card is inserted. Copy fails saying it is a read only file system
		return False
		
	
	cmd = '../adb.exe shell ls -l ./storage/sdcard1/sd-card_test.txt'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	returnString = returnString[35:37]
	
	if not returnString.strip() == '18':
		return False
		
	cmd = '../adb.exe shell rm ./storage/sdcard1/sd-card_test.txt'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	if returnString == '':
		return True
	else:
		return False
	
def retryPrompt(dict):

	while True:
		inputStr = 'SD Card ' + dict['TestFail'] + '. Can\'t find SD Card. ' + dict['RetryPrompt']
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
		resultBool = sdCardTest(dict)
		if resultBool:
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	if resultBool:
		print(Fore.GREEN + '** SD Card', dict['TestPassDash'] + Style.RESET_ALL)
	else:
		print(Fore.RED + ' ** SD Card', dict['TestFailDash'] + Style.RESET_ALL)
		
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('sdCardTest', True)
		else:
			DBUtil.updateLastTestResult('sdCardTest', False)

# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	