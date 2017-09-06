#!/usr/bin/python
import sys
import string
import os
import subprocess
from colorama import Fore, Back, Style

#**********************
#     Version Test
#**********************

def getOSVersion():
	
	cmd = '../adb.exe shell getprop ro.build.display.id'
	s = subprocess.check_output(cmd.split())
	returnString = s.decode("ascii")
	
	return returnString.strip()

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
		print(Fore.RED + '** OS version', dict['TestFailDash'], ': Error, no OS version string in the configuration file. Contact MICRONET for the OS string' + Style.RESET_ALL)
		osExistBoolean = False
	if not 'mcu_ver' in configDict:
		print(Fore.RED + '** MCU version', dict['TestFailDash'], ': Error, no MCU version string in the configuration file. Contact MICRONET for the MCU string' + Style.RESET_ALL)
		mcuExistBoolean = False
	if not 'fpga_ver' in configDict:
		print(Fore.RED + '** FPGA version', dict['TestFailDash'], ': Error, no FPGA version string in the configuration file. Contact MICRONET for the FPGA string' + Style.RESET_ALL)
		fpgaExistBoolean = False
		
	deviceOSVer = getOSVersion()
	deviceMCUVer = getMCUVersion()
	deviceFPGAVer = getFPGAVersion()
	
	if osExistBoolean:
		if deviceOSVer.strip().lower() == configDict['os_ver'].strip().lower():
			osBoolean = True
		else:
			print(Fore.RED + ' ** OS version', dict['TestFailDash'], ': expected', configDict['os_ver'], 'got', deviceOSVer, '. Burn correct OS version.' + Style.RESET_ALL)
			osBoolean = False
	
	if mcuExistBoolean:
		if deviceMCUVer.strip().lower() == configDict['mcu_ver'].strip().lower():
			mcuBoolean = True
		else:
			print(Fore.RED + ' ** MCU version', dict['TestFailDash'], ': expected', configDict['mcu_ver'], 'got', deviceMCUVer, '. Burn correct MCU version.' + Style.RESET_ALL)
			mcuBoolean = False
	
	if fpgaExistBoolean:	
		if deviceFPGAVer.strip().lower() == configDict['fpga_ver'].strip().lower():
			fpgaBoolean = True
		else:
			print(Fore.RED + ' ** FPGA version', dict['TestFailDash'], ': expected', configDict['fpga_ver'], 'got', deviceFPGAVer, '. Burn correct FPGA version.' + Style.RESET_ALL)
			fpgaBoolean = False
		
	if osExistBoolean and osBoolean and mcuExistBoolean and mcuBoolean and fpgaExistBoolean and fpgaBoolean:
		print(Fore.GREEN + '** Version ' + dict['TestPassDash'] + Style.RESET_ALL)
	else:
		print(Fore.RED + '** Version', dict['TestFailDash'] + Style.RESET_ALL)
		
	####
	#### TODO: Handle empty version strings in failures.
	####	
	if update:
		if osExistBoolean and osBoolean and mcuExistBoolean and mcuBoolean and fpgaExistBoolean and fpgaBoolean:
			DBUtil.updateLastTestResult('versionTest', True)
		else:
			DBUtil.updateLastTestResult('versionTest', False)
		
		DBUtil.updateLastTestResult('os_ver', deviceOSVer)
		DBUtil.updateLastTestResult('mcu_ver', deviceMCUVer)
		DBUtil.updateLastTestResult('fpga_ver', deviceFPGAVer)

# If this script is called directly then run the main function	
if __name__ == "__main__":
	import DBUtil
	import TestUtil
	import colorama
	colorama.init()
	langDict = TestUtil.getLanguageDictSoloTest()
	configDict = TestUtil.getConfigurationsDictSoloTest()
	Main(langDict, configDict, False)
else:
	import OBC_TEST_FILES.TestUtil as TestUtil
	import OBC_TEST_FILES.DBUtil as DBUtil	


