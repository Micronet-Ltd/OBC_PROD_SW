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
	
	print(returnString)
	
	# Find index of return code and return data
	index = returnString.find('result=') + 7
	resultCode = returnString[index:index + 1]
	
	index = returnString.find('"')
	endIndex = returnString.find('"')
	resultData = returnString[index:endIndex+1]
	
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

def Main(dict):

	print('\n')
	continueTesting = True
	data = ()

	while continueTesting == True:
		data = j1708Test()
		if data[0] == '1':
			continueTesting = False
			break
		else:
			continuteTesting = retryPrompt(dict)

	
	if data[0] == '1':
		print('J1708 ', dict['TestPassDash'])
	else:
		print('J1708 ', dict['TestFailDash'], ' ', data[1])

	
	
	