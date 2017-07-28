#!/usr/bin/python
import sys
import string
import os
import subprocess
import time

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
	
	rootHotspotConnected = False
	
	# Make ADB root and connect again
	for i in range(8):
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
			break
			
		time.sleep(1)
		
	if not rootHotspotConnected:
		return False
	
	rootADB = False
	
	for i in range(8):	
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
		print('** adb Connected passed')
		return True
	else:
		print(' ** adb Connected failed')
		return False
		
	

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("ADB Connect is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	Main(langDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	