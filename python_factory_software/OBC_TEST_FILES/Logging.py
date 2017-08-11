#!/usr/bin/python
import sys
import string
import os
import subprocess

#**********************
#       Logging
#**********************

def Main(name):
	with open('{}.txt'.format(name), 'w') as out:
		subprocess.call(['../adb.exe', 'logcat'], stdout=out)

		
# If this script is called directly then run the main function	
if __name__ == "__main__":
	Main('Carl')
else:
	Main()