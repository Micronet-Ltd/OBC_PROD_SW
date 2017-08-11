#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#       NFC Test
#**********************

def nfcTest(dict):
	
	print(dict['NFCPrompt'])
	
	count = 0
	
	nfcTextGenerated = False
	
	for i in range(75):
		# Read the file size 
		cmd = '../adb.exe shell ls -l ./sdcard/nfc.txt'
		s = subprocess.check_output(cmd.split())
		returnString = s.decode("ascii")
		
		returnString = returnString[35:37]
		
		if returnString.strip() == '8' or returnString.strip() == '14' or returnString.strip() == '16':
			nfcTextGenerated = True
			break
	
	# If the text file was not generated that means that NFC failed
	if not nfcTextGenerated:
		return False
	
	# Try to delete the file
	cmd = '../adb.exe shell rm ./sdcard/nfc.txt'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	# Nothing should be returned from the deletion if it deletes successfully
	if not returnString == '':
		return False
	
	# If everything has passed so far then uninstall APK
	uninstallAPK()
	return True

def uninstallAPK():
	cmd = '../adb.exe uninstall me.davidvassallo.nfc'
	s = subprocess.check_output(cmd.split())
	
def retryPrompt(dict):

	while True:
		choice = input(dict['NFCRetryPrompt'])
	
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
		resultBool = nfcTest(dict)
		if resultBool:
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	if resultBool:
		print(Fore.GREEN + dict['NFCPass'] + Style.RESET_ALL)
	else:
		print(Fore.RED + dict['NFCFail'] + Style.RESET_ALL)
	
	if not resultBool:
		uninstallAPK()
		# Try to delete file just in case. (This is from the original code)
		cmd = '../adb.exe shell rm ./sdcard/nfc.txt'
		s = subprocess.check_output(cmd.split())
		
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('nfcTest', True)
		else:
			DBUtil.updateLastTestResult('nfcTest', False)

# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	