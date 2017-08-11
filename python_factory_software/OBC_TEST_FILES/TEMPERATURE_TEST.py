#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#   Temperature Test
#**********************

def tempTest():
	cmd = '../adb.exe shell mctl api 02040A'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	returnString = returnString[25:29]
	temperature = int(returnString)
	temperature = (temperature - 500)/10
	
	return temperature			

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()
	
	temp = tempTest()
	if temp >= 20 and temp <= 50:
		print(Fore.GREEN + '** Temperature' , dict['TestPassDash'], '==', temp, Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + ' ** Temperature' , dict['TestFailDash'], 'Expected temperature 20-50c, got', temp, Style.RESET_ALL)
		resultBool = False
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('temperatureTest', True)
		else:
			DBUtil.updateLastTestResult('temperatureTest', False)


# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil