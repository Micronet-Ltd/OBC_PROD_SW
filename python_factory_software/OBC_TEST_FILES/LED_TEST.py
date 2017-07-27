#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#       LED Test
#**********************

def setupLEDS():
	# Change LEDs to all white
	cmd = '..\adb shell mctl api 0206000FFFFFFF'
	s = subprocess.check_output(cmd.split())
	cmd = '..\adb shell mctl api 0206010FFFFFFF'
	s = subprocess.check_output(cmd.split())
	cmd = '..\adb shell mctl api 0206020FFFFFFF'
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
	cmd = '..\adb shell mctl api 02060000FF0000'
	s = subprocess.check_output(cmd.split())
	cmd = '..\adb shell mctl api 02060100FF0000'
	s = subprocess.check_output(cmd.split())
	cmd = '..\adb shell mctl api 0206020F00FF00'
	s = subprocess.check_output(cmd.split())

#**********************
#     Main Script
#**********************

def Main(dict):

	print('\n')
	
	# Change color of LEDS to all white
	setupLEDS()
	
	# Ask Tester if LEDs are correct brightness and color
	choice = ledPrompt(dict)
	
	if choice == True:
		print(dict['LEDPass'])
	else:
		print(dict['LEDFail'])
	
	# Change LEDs back to default
	reconfigureLEDS()

	
	
	