#!/usr/bin/python
import sys
import string
import os
import subprocess
import time
import re
from threading import Thread
appName = "OBC 5 Serial # and IMEI Pull"
appVersion = "0.3"

filename = "testResults/SerialIMEI.csv"
count = 1

# **************************
# loginfo function
# **************************

def loginfo(stuff2log):

	if (os.path.isfile(filename)) == False:
		try:
			f = open(filename, 'a')
			# FORMAT is: Serial Number,IMEI
			f.write("Serial Number,IMEI\n")
		except IOError:
			print("Error: can\'t find file or read data.")
		else:
			f.close()

	try:
		f = open(filename, 'a')
		f.write(stuff2log + "\n")
		
	except IOError:
		print("Error: can\'t find file or read data.")
	else:
		f.close()
	
	return;
	
# **************************
# getIMEI function
# **************************

def getIMEI():
	
	imeiValue = -1
	
	# cmd = '../adb.exe wait-for-device root' - The "adb_CONNECT.bat" Batch file is handling the root.
	# s = subprocess.check_output(cmd.split())
				
	cmd = '../adb.exe wait-for-device shell service call iphonesubinfo 1'
	s = subprocess.check_output(cmd.split())
	adbRetVal = s.decode("ascii")
	
	#Deletes all periods in string
	reducedOne = re.sub('[.]', '', adbRetVal)
		
	# Strip to first four digits of IMEI number
	reducedTwo = reducedOne[reducedOne.find('\'')+1:]
	imeiNumberOne = reducedTwo[:4]
			
	# Strip to next 8 digits of IMEI number
	reducedThree = reducedTwo[reducedTwo.find('\'')+1:]
	reducedThree = reducedThree[reducedThree.find('\'')+1:]
	imeiNumberTwo = reducedThree[:8]
			
	# Strip to next 3 digits of IMEI number
	reducedFour = reducedThree[reducedThree.find('\'')+1:]
	reducedFour = reducedFour[reducedFour.find('\'')+1:]
	imeiNumberThree = reducedFour[:3]
		
	imeiValue = imeiNumberOne + imeiNumberTwo + imeiNumberThree 
		
	return imeiValue;

# **************************
# getSerialNumber function
# **************************
	
def getSerialNumber():

	serialNumber = ""
	
	# cmd = '../adb.exe wait-for-device root' - The "adb_CONNECT.bat" Batch file is handling the root.
	# s = subprocess.check_output(cmd.split())
	
	cmd = '../adb.exe wait-for-device shell getprop | grep ro.serialno'
	s = subprocess.check_output(cmd.split())
	adbRetVal = s.decode("ascii")
	
	serialNumber = adbRetVal[16:24]
	
	serialNumber = serialNumber.upper()
	
	print('Serial Number: %s\r\n' % (serialNumber))
	
	return serialNumber

# **************************
# getCheckIMEI function
# **************************
def getCheckIMEI():

	global count

	if(count > 10):
		print('Error getting IMEI. Device needs to be rescanned.')
		return -1
	
	imeiValue = getIMEI()
	
	# If IMEI is correct length and a number, then continue.
	if(isNumber(imeiValue) and len(imeiValue) == 15):
		print('IMEI Value: %s\r\n' % (imeiValue))
		
		# Added to write IMEI to file to check IMEI on the device vs the IMEI on the label
		try:
			fh = open('IMEIrsult.txt', 'w')
			fh.write(str(imeiValue)+"\n")
			fh.close()
		except:
			print('Error writing IMEI to IMEIrsult.txt')
		
		return imeiValue
		
	else:
		count = count + 1
		print('Trying Again: Test %d \r' % (count))
		time.sleep(5)
		getCheckIMEI()	
	
# **************************
# isNumber function
# **************************	

def isNumber(inputValue):
	try:
		float(inputValue)
		return True
	except ValueError:
		return False
	

# **************************
# Script MAIN Starts here
# **************************


#Clear the screen and set colors to normal
os.system('color 07')

print('%s, Version: %s \r\n' % (appName, appVersion))

imeiValue = getCheckIMEI()
serialNumber = getSerialNumber()

try:
	loginfo('%s,%s' % (serialNumber, imeiValue))
	input('Press enter to continue')
except:
	input('There was an error writing to SerialImei.csv.')
	
	