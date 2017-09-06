#!/usr/bin/python
import sys
import string
import os
import subprocess
import time
import colorama
import zipfile
from colorama import Fore, Back, Style
from OBC_TEST_FILES import *

def runIndividualTests(langDict, configDict, testDict, test_script_version):

	tryToConnect = True
	
	while tryToConnect:
		# Connect over ADB hotspot
		connectedBool = ADB_CONNECT.Main()
		if(connectedBool):
			tryToConnect = False
			break
		else:
			print()
			choice = input("Try to connect to device again? [Y/N]: ")
			selection = True
			while(selection):
				if choice.lower() == 'y':
					tryToConnect = True
					selection = False
				elif choice.lower() == 'n':
					tryToConnect = False
					selection = False
					print()
					print(Fore.CYAN + 'Exiting test... ' + Style.RESET_ALL)
					sys.exit()
				else:
					print('Invalid option. Please select either [Y/N]')
					selection = True
			
	
	# If test is able to connect to device then right to the database
	testResult = DBUtil.TestResult(test_ver = test_script_version, test_type = configDict['test_type'])
	DBUtil.startSession()
	DBUtil.insertTestResult(testResult)
	
	# Install Test Files
	INSTALL_FILES_TEST.Main()
	
	# Run Serial Test
	if 'SerialTest' in testDict:
		SERIAL_TEST.Main(langDict)
	
	# Run IMEI Test
	if 'IMEITest' in testDict:
		IMEI_TEST.Main(langDict)

	# Check for duplicate devices
	deviceSerial = DBUtil.getLastInserted().serial
	deviceIMEI = DBUtil.getLastInserted().imei
	duplicate = DBUtil.searchForDuplicates(deviceIMEI, deviceSerial)

	if duplicate:
		print()
		choice = input(Fore.RED + "Duplicate IMEI or Serial found. Would you like to continue testing? [Y/N]: " + Style.RESET_ALL)
		selection = True
		while(selection):
			if choice.lower() == 'y':
				selection = False
			elif choice.lower() == 'n':
				selection = False
				print()
				print(Fore.CYAN + 'Exiting test... ' + Style.RESET_ALL)
				sys.exit()
			else:
				print('Invalid option. Please select either [Y/N]')
				selection = True

	
	# Run Version Test
	if 'VersionTest' in testDict:
		VERSION_TEST.Main(langDict, configDict)
	
	# Run LED Test
	if 'LEDTest' in testDict:
		LED_TEST.Main(langDict)
	
	# Run SD Card Test
	if 'SDCardTest' in testDict:
		SD_CARD_TEST.Main(langDict)
	
	# Run Cellular Test
	if 'CellularTest' in testDict:
		CELLULAR_TEST.Main(langDict, configDict)
	
	# Run CANBus Test
	if 'CANBusTest' in testDict:
		CANBUS_TEST.Main(langDict)
	
	# Run SWC Test
	if 'SWCTest' in testDict:
		SWC_TEST.Main(langDict)
	
	# Run J1708 Test
	if 'J1708Test' in testDict:
		J1708_TEST.Main(langDict)
	
	# Run COM Test
	if 'COMTest' in testDict:
		COM_TEST.Main(langDict)
	
	# Run NFC Test
	if 'NFCTest' in testDict:
		NFC_TEST.Main(langDict)
	
	# Run Help Key Test
	if 'HelpKeyTest' in testDict:
		HELP_KEY_TEST.Main(langDict)
	
	# Run Audio Test
	if 'AudioTest' in testDict:
		AUDIO_TEST.Main(langDict)
	
	# Run Temperature Test
	if 'TemperatureTest' in testDict:
		TEMPERATURE_TEST.Main(langDict)
	
	# Run ReadRTC Test
	if 'ReadRTCTest' in testDict:
		ReadRTC_TEST.Main(langDict)
	
	# Run Accelerometer Test
	if 'AccelerometerTest' in testDict:
		ACCELEROMETER_TEST.Main(langDict)
	
	# Run GPIO Test
	if 'GPIOTest' in testDict:
		GPIO_TEST.Main(langDict)
		
	# Run GPIO Inputs Only Test
	if 'GPIOInputsTest' in testDict:
		GPIO_INPUTS_TEST.Main(langDict)
	
	# Run Wiggle Test
	if 'WiggleTest' in testDict:
		WIGGLE_TEST.Main(langDict)
		
	# Run Supercap Test
	if 'SupercapTest' in testDict:
		SUPERCAP_TEST.Main(langDict)

# Main Script starts here
def Main():

	# Start Time
	startTime = time.time()

	# Clear Screen
	os.system('cls')
	
	# Initialize Colorama
	colorama.init()
	
	print(Style.RESET_ALL, end="")

	test_script_version = 'PY_1.2.30'

	print('---------------------------------------------------')
	print(Fore.CYAN + ' starting test, test script version is : ' + test_script_version + Style.RESET_ALL)
	print('---------------------------------------------------')
	

	# Get dictionary with configurations
	configDict = TestUtil.getConfigurationsDict()
	# Get language dictionary
	langDict = TestUtil.getLanguageDict()
	# Get test dicitonary
	testDict = TestUtil.getTestDict()
	
	# It's important to change directories for adb cmd strings to work properly
	os.chdir('OBC_TEST_FILES')
	
	# ----- RUN INDIVIDUAL TESTS -----
	runIndividualTests(langDict, configDict, testDict, test_script_version)
	
	# ----- CHECK TEST RESULTS -----
	failures = DBUtil.returnListOfFailures(testDict)
	
	print()
	
	if len(failures) == 0:
		print(Fore.GREEN +'**************************************')
		print('***** Entire OBC', langDict['TestPass'],'!!! *****')
		print('**************************************' + Style.RESET_ALL)
		DBUtil.updateLastTestResult('allPassed', True)
	else:
		print(Fore.RED + '**************************************')
		print('********  OBC', langDict['TestFail'],'!!! ********')
		print('**************************************')
		DBUtil.updateLastTestResult('allPassed', False)
		
		print()
		
		print(langDict['FailedTestsPrompt'])
		
		for x in failures:
			print(' **', x, ':',langDict['TestFail'])
			
		print(Style.RESET_ALL, end="")
	
	# Disconnect ADB from device
	cmd = '../adb.exe disconnect'
	s = subprocess.check_output(cmd.split())
	time.sleep(2)
	
	# Get total runtime
	totalRunTime = int(time.time() - startTime)
	DBUtil.updateLastTestResult('runTime', totalRunTime)
	
	
	
# If this script is called directly then run the main function	
if __name__ == "__main__":
	try:
		Main()
	except KeyboardInterrupt:
		print()
		print(Fore.CYAN + 'Shutdown requested... exiting' + Style.RESET_ALL)
		cmd = '../adb.exe disconnect'
		s = subprocess.check_output(cmd.split())
