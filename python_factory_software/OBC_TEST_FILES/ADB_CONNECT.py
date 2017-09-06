#!/usr/bin/python
import sys
import string
import os
import subprocess
import time
from colorama import Fore, Back, Style

#**********************
#     ADB Connect
#**********************

def adbConnect():

	hotspotConnected = False
	
	for i in range(20):
		
		print('.', end="")
		
		with open(os.devnull, 'w') as nul:
			cmd = '../adb.exe connect 192.168.43.1'
			s = subprocess.check_output(cmd.split(), stderr=nul)
			returnString = s.decode("ascii")
		
		returnString = returnString[:1]
		
		if returnString == 'c' or returnString == 'a':
			# Connected to hotspot
			hotspotConnected = True
			break

	
	if not hotspotConnected:
		return False
	
	# Make ADB root and connect again
	for i in range(8):
		rootHotspotConnected = False
		rootString = ''
	
		try:
			with open(os.devnull, 'w') as nul:
				cmd = '../adb.exe root'
				s = subprocess.check_output(cmd.split(), stderr=nul)
				cmd = '../adb.exe connect 192.168.43.1'
				s = subprocess.check_output(cmd.split(), stderr=nul)
				rootString = s.decode("ascii")
			
			rootString = rootString[:1]
		except subprocess.CalledProcessError:
			rootString='Error'
		
		if rootString == 'c' or rootString == 'a':
			# Connected to hotspot
			rootHotspotConnected = True
			
		time.sleep(1)
		
		rootADB = False
		
		if rootHotspotConnected:
		
			# Check device state
			with open(os.devnull, 'w') as nul:
				cmd = '../adb.exe get-state'
				s = subprocess.check_output(cmd.split(), stderr=nul)
				state = s.decode("ascii")
			
			if state.strip() == 'device':
				time.sleep(2)
				# Check that ADB is actually root
				with open(os.devnull, 'w') as nul:
					cmd = '../adb.exe shell id'
					s = subprocess.check_output(cmd.split(), stderr=nul)
					root = s.decode("ascii")
				
				root = root[:11]
				
				if root == 'uid=0(root)':
					rootADB = True
					break
			
	if rootADB:
		return True
	else:
		return False

#**********************
#     Main Script
#**********************

def Main():
	
	resultBool = adbConnect()
	
	print('', end='\r', flush=True)
	
	if resultBool:
		print(Fore.GREEN + '** adb Connected passed' + Style.RESET_ALL)
		return True
	else:
		print(Fore.RED + ' ** adb Connected failed' + Style.RESET_ALL)
		return False
		
	

# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	import colorama
	colorama.init()
	langDict = TestUtil.getLanguageDictSoloTest()
	Main()
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	