#!/usr/bin/python
import sys
import string
import os
import subprocess
import time
import re
from threading import Thread
appName = "OBC 5 Serial # and IMEI Pull"
appVersion = "0.2"

filename = "testResults/SerialIMEI.csv"

# **************************
# loginfo function
# **************************

def loginfo(stuff2log,includeTime):

	if (os.path.isfile(filename)) == False:
		try:
			f = open(filename, 'a')
			# FORMAT is: Serial Number, IMEI
			f.write("Serial Number, IMEI\n")
		except IOError:
			print("Error: can\'t find file or read data.")
		else:
			f.close()
	
	localtime = time.asctime( time.localtime(time.time()) )

	try:
		f = open(filename, 'a')
		if includeTime == False:
			f.write(stuff2log + "\n")
		else:
			f.write(localtime + ", " + stuff2log + "\n")
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
	
#	cmd = '../adb.exe root'   - The "adb_CONNECT.bat" Batch file is handling the root. 
#	s = subprocess.check_output(cmd.split())
				
	cmd = '../adb.exe shell service call iphonesubinfo 1'
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
		
	print('IMEI Value: ')
	print(imeiValue)
	print('\r')
	fh = open('IMEIrsult.txt', 'w')
	fh.write(str(imeiValue)+"\n")
	fh.close()
	
				
	return imeiValue;

# **************************
# getSerialNumber function
# **************************
	
def getSerialNumber():

	serialNumber = ""
	
#	cmd = '../adb.exe root' - The "adb_CONNECT.bat" Batch file is handling the root.
#	s = subprocess.check_output(cmd.split())
	
	cmd = '../adb.exe shell getprop | grep ro.serialno'
	s = subprocess.check_output(cmd.split())
	adbRetVal = s.decode("ascii")
	
	serialNumber = adbRetVal[16:24]
	
	serialNumber = serialNumber.upper()
	
	print('Serial Number: ')
	print(serialNumber)
	print('\r')
	
	return serialNumber
	
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

# Gets the IMEI number.		
	
imeiValue = getIMEI()
imeiBoolean = False

# Checks to see if it is a number and has the correct length		
if(isNumber(imeiValue) and len(imeiValue) == 15):
	imeiBoolean = True
else:
	print('IMEI not found or not read correctly.\r\n')

# Gets the Serial Number

serialNumberBoolean = False	
serialNumber = getSerialNumber()

# Check to see if correct length
if(len(serialNumber) == 8):
	serialNumberBoolean = True
else:
	print('Serial Number not found or not read correctly.\r\n')

#If both are true, proceed to write to .csv file
if(imeiBoolean == True and serialNumberBoolean == True):
	loginfo('%s, %s' % (serialNumber, imeiValue), False)
else:
	print("Error in reading Serial Number and IMEI")

