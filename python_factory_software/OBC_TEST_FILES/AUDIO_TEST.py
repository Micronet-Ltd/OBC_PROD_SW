#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#     Audio Test
#**********************

def audioTest(dict):
	
	# These turn off both speakers 
	cmd = '../adb.exe shell mctl api 0213000600'
	s = subprocess.check_output(cmd.split())
	cmd = '../adb.exe shell mctl api 0213001C00'
	s = subprocess.check_output(cmd.split())
	
	# Testing right speaker
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT'
	s = subprocess.check_output(cmd.split())
	# This turns the right speaker on.
	cmd = '../adb.exe shell mctl api 0213000601' 
	s = subprocess.check_output(cmd.split())
	# This turns the left speaker off.
	cmd = '../adb.exe shell mctl api 0213001C00' 
	s = subprocess.check_output(cmd.split())
	
	# Right speaker validation
	while True:
		choice = input(dict['RightSpeakerPrompt'])
	
		if choice.lower() == 'y':
			rightSpeakerBool = True
			break
		elif choice.lower() == 'n':
			rightSpeakerBool = False
			break
		else:
			print('Invalid option. Please select either [Y/N]')
	
	# Testing left speaker
	cmd = '../adb.exe shell am broadcast -a com.micronet.obctestingapp.GET_AUDIO_RESULT'
	s = subprocess.check_output(cmd.split())
	# This turns the left speaker on.
	cmd = '../adb.exe shell mctl api 0213001C01' 
	s = subprocess.check_output(cmd.split())
	# This turns the right speaker off.
	cmd = '../adb.exe shell mctl api 0213000600' 
	s = subprocess.check_output(cmd.split())
	
	# Right speaker validation
	while True:
		choice = input(dict['LeftSpeakerPrompt'])
	
		if choice.lower() == 'y':
			leftSpeakerBool = True
			break
		elif choice.lower() == 'n':
			leftSpeakerBool = False
			break
		else:
			print('Invalid option. Please select either [Y/N]')
	
	if rightSpeakerBool and leftSpeakerBool:
		return True
	else:
		return False
	
	
def retryPrompt(dict):

	while True:
		choice = input(dict['AudioRetryPrompt'])
	
		if choice.lower() == 'y':
			return True
		elif choice.lower() == 'n':
			return False
		else:
			print('Invalid option. Please select either [Y/N]')

def turnOffSpeakers():
	# This turns off both speakers. I'm not sure we need to do this but I'll leave it for now.
	cmd = '../adb.exe shell mctl api 0213000600' 
	s = subprocess.check_output(cmd.split())
	cmd = '../adb.exe shell mctl api 0213001C00' 
	s = subprocess.check_output(cmd.split())
			
#**********************
#     Main Script
#**********************

def Main(dict, update=True):

	print()
	
	continueTesting = True

	while continueTesting:
		resultBool = audioTest(dict)
		if resultBool:
			continueTesting = False
			break
		else:
			continueTesting = retryPrompt(dict)
	
	turnOffSpeakers()
	
	if resultBool:
		print('** Audio', dict['TestPassDash'])
	else:
		print(' ** Audio', dict['TestFailDash'])
	
		
	if update:
		if resultBool:
			DBUtil.updateLastTestResult('audioTest', True)
		else:
			DBUtil.updateLastTestResult('audioTest', False)

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("Audio Test is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	