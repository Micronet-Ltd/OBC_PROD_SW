#!/usr/bin/python
import sys
import string
import os
import subprocess
import datetime
from colorama import Fore, Back, Style

#**********************
#     ReadRTC Test
#**********************

def readRTCTest():
	cmd = '../adb.exe shell mctl api 020B'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	index = returnString.find('ret = ') + 6
	
	returnString = returnString[index:index+1]
	
	return returnString

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()
	
	returnString = readRTCTest()
	
	if returnString == '8':
		print(Fore.GREEN + '** ReadRTC', dict['TestPassDash'] +Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + ' ** ReadRTC', dict['TestFailDash'], 'return code should be 8, but was', returnString + Style.RESET_ALL)
		resultBool = False
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('readRTCTest', True)
		else:
			DBUtil.updateLastTestResult('readRTCTest', False)


# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil