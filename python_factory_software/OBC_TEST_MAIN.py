#!/usr/bin/python
import sys
import string
import os
import subprocess
import time
from OBC_TEST_FILES import *

def runIndividualTests(langDict, configDict, testDict, test_script_version):
	# Connect over ADB hotspot
	connectedBool = ADB_CONNECT.Main()
	
	if not connectedBool:
		print('Test ERROR: No device connected.')
		print('Please make sure device is set up correctly and restart test.')
		sys.exit()
	
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
	
	# Run Version Test
	if 'VersionTest' in testDict:
		VERSION_TEST.Main(langDict, configDict)
	
	# Run LED Test
	if 'LEDTest' in testDict:
		LED_TEST.Main(langDict)
	
	# Run SD Card Test
	if 'SDCardTest' in testDict:
		SD_CARD_TEST.Main(langDict)
	
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
		#SUPERCAP_TEST.Main(langDict)
		pass

# Main Script starts here
def Main():

	test_script_version = '1.2.25'

	print('---------------------------------------------------')
	print('starting test, test script version is : ', test_script_version)
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
		os.system('color 20')
		print('**************************************')
		print('***** Entire OBC', langDict['TestPass'],'!!! *****')
		print('**************************************')
		DBUtil.updateLastTestResult('allPassed', True)
	else:
		os.system('color 47')
		print('**************************************')
		print('********  OBC', langDict['TestFail'],'!!! ********')
		print('**************************************')
		DBUtil.updateLastTestResult('allPassed', False)
		
		print(langDict['FailedTestsPrompt'])
		
		for x in failures:
			print(' **', x, ':',langDict['TestFail'])
	
	cmd = '../adb.exe disconnect'
	s = subprocess.check_output(cmd.split())
	time.sleep(2)
	
	os.system('color 07')
	
	
# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("OBC_TEST_MAIN is being called directly")
	Main()
