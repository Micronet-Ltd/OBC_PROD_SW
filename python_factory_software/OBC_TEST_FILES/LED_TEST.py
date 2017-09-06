#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#       LED Test
#**********************

def setupLEDS():
	# Change LEDs to all white
	cmd = '../adb shell mctl api 0206000FFFFFFF'
	s = subprocess.check_output(cmd.split())
	cmd = '../adb shell mctl api 0206010FFFFFFF'
	s = subprocess.check_output(cmd.split())
	cmd = '../adb shell mctl api 0206020FFFFFFF'
	s = subprocess.check_output(cmd.split())
	

def ledPrompt(dict):

	while True:
		choice = input(dict['LEDPrompt'])
	
		if choice.lower() == 'y':
			return True
		elif choice.lower() == 'n':
			return False
		else:
			print('Invalid option. Please select either [Y/N]')
			

def reconfigureLEDS():
	# Change LEDs back to default
	cmd = '../adb shell mctl api 02060000FF0000'
	s = subprocess.check_output(cmd.split())
	cmd = '../adb shell mctl api 02060100FF0000'
	s = subprocess.check_output(cmd.split())
	cmd = '../adb shell mctl api 0206020F00FF00'
	s = subprocess.check_output(cmd.split())

#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()
	
	# Change color of LEDS to all white
	setupLEDS()
	
	# Ask Tester if LEDs are correct brightness and color
	choice = ledPrompt(dict)
	
	if choice == True:
		print(Fore.GREEN + dict['LEDPass'] + Style.RESET_ALL)
		resultBool = True
	else:
		print(Fore.RED + dict['LEDFail'] + Style.RESET_ALL)
		resultBool = False
	
	# Change LEDs back to default
	reconfigureLEDS()
	
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('ledTest', True)
		else:
			DBUtil.updateLastTestResult('ledTest', False)

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
	
	