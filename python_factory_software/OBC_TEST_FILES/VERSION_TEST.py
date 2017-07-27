#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#     Version Test
#**********************

def getOSVersion():
	
	cmd = '../adb.exe shell getprop ro.build.display.id'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	return returnString

def getMCUVersion():
	
	cmd = '../adb.exe shell mctl api 0200'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	returnString = returnString[28:35]
	
	return returnString
	
def getFPGAVersion():
	
	cmd = '../adb.exe shell mctl api 0201'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	returnString = returnString[9:19]
	
	return returnString
		

#**********************
#     Main Script
#**********************

def Main(dict, configDict, update=True):

	print()
	
	osExistBoolean = True
	mcuExistBoolean = True
	fpgaExistBoolean = True
	
	# Check to make sure the configurations exist in the dictionary
	if not 'os_ver' in configDict:
		print('** OS version', dict['TestFailDash'], ': Error, no OS version string in the configuration file. Contact MICRONET for the OS string')
		osExistBoolean = False
	if not 'mcu_ver' in configDict:
		print('** MCU version', dict['TestFailDash'], ': Error, no MCU version string in the configuration file. Contact MICRONET for the MCU string')
		mcuExistBoolean = False
	if not 'fpga_ver' in configDict:
		print('** FPGA version', dict['TestFailDash'], ': Error, no FPGA version string in the configuration file. Contact MICRONET for the FPGA string')
		fpgaExistBoolean = False
		
	deviceOSVer = getOSVersion()
	deviceMCUVer = getMCUVersion()
	deviceFPGAVer = getFPGAVersion()
	
	if osExistBoolean:
		if deviceOSVer.strip().lower() == configDict['os_ver'].strip().lower():
			osBoolean = True
		else:
			print(' ** OS version', dict['TestFailDash'], ': expected', configDict['os_ver'], 'got', deviceOSVer, '. Burn correct OS version.')
			osBoolean = False
	
	if mcuExistBoolean:
		if deviceMCUVer.strip().lower() == configDict['mcu_ver'].strip().lower():
			mcuBoolean = True
		else:
			print(' ** MCU version', dict['TestFailDash'], ': expected', configDict['mcu_ver'], 'got', deviceMCUVer, '. Burn correct MCU version.')
			mcuBoolean = False
	
	if fpgaExistBoolean:	
		if deviceFPGAVer.strip().lower() == configDict['fpga_ver'].strip().lower():
			fpgaBoolean = True
		else:
			print(' ** FPGA version', dict['TestFailDash'], ': expected', configDict['fpga_ver'], 'got', deviceFPGAVer, '. Burn correct FPGA version.')
			fpgaBoolean = False
		
	if osExistBoolean and osBoolean and mcuExistBoolean and mcuBoolean and fpgaExistBoolean and fpgaBoolean:
		print('** Version', dict['TestPassDash'])
	else:
		print('** Version', dict['TestFailDash'])
		
	####
	#### TODO: Handle empty version strings in failures.
	####	
	if update:
		testResult = DBUtil.getLastInserted()
		if osExistBoolean and osBoolean and mcuExistBoolean and mcuBoolean and fpgaExistBoolean and fpgaBoolean:
			testResult.versionTest = True
		else:
			testResult.versionTest = False
		
		testResult.os_ver = deviceOSVer
		testResult.mcu_ver = deviceMCUVer
		testResult.fpga_ver = deviceFPGAVer
		
		print('Object has been updated from Version_TEST')
		DBUtil.commitSession()

# If this script is called directly then run the main function	
if __name__ == "__main__":
	print("Version Test is being called directly")
	import DBUtil
	import TestUtil
	langDict = TestUtil.getLanguageDictSoloTest()
	configDict = TestUtil.getConfigurationsDictSoloTest()
	Main(langDict, configDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	


