#!/usr/bin/python
import sys
import string
import os
import subprocess
from OBC_TEST_FILES import *

# Main Script starts here
def Main():

	test_script_version = '1.2.24'

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
	
	testResult = DBUtil.TestResult(test_ver = test_script_version, test_type = configDict['test_type'])
	
	DBUtil.startSession()
	DBUtil.insertTestResult(testResult)
	
	# Connect over ADB hotspot
	if 'adbHotspot' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Install Test Files
	if 'installTestFiles' in testDict:
		# Run Test and use result
		#INSTALL_FILES_TEST.Main()
		pass
	else:
		# Write N/A to file
		pass
		
	# Run Serial Test
	if 'SerialTest' in testDict:
		# Run Test and use result
		SERIAL_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run IMEI Test
	if 'IMEITest' in testDict:
		# Run Test and use result
		IMEI_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run Version Test
	if 'VersionTest' in testDict:
		# Run Test and use result
		VERSION_TEST.Main(langDict, configDict)
	else:
		# Write N/A to file
		pass
	
	# Run LED Test
	if 'LEDTest' in testDict:
		# Run Test and use result
		LED_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run SD Card Test
	if 'SDCardTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Run CANBus Test
	if 'CANBusTest' in testDict:
		# Run Test and use result
		CANBUS_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run SWC Test
	if 'SWCTest' in testDict:
		# Run Test and use result
		SWC_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run J1708 Test
	if 'J1708Test' in testDict:
		# Run Test and use result
		J1708_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run COM Test
	if 'COMTest' in testDict:
		# Run Test and use result
		COM_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run NFC Test
	if 'NFCTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Run Help Key Test
	if 'HelpKeyTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Run Audio Test
	if 'AudioTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Run Temperature Test
	if 'TemperatureTest' in testDict:
		# Run Test and use result
		TEMPERATURE_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run ReadRTC Test
	if 'ReadRTC' in testDict:
		# Run Test and use result
		ReadRTC_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run Accelerometer Test
	if 'AccelerometerTest' in testDict:
		# Run Test and use result
		ACCELEROMETER_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run GPIO Test
	if 'GPIOTest' in testDict:
		# Run Test and use result
		GPIO_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
		
	# Run GPIO Inputs Only Test
	if 'GPInputsOnlyTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass
	
	# Run Wiggle Test
	if 'WiggleTest' in testDict:
		# Run Test and use result
		WIGGLE_TEST.Main(langDict)
	else:
		# Write N/A to file
		pass
	
	# Run Supercap Test
	if 'SupercapTest' in testDict:
		# Run Test and use result
		pass
	else:
		# Write N/A to file
		pass

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("OBC_TEST_MAIN is being called directly")
	Main()
