#!/usr/bin/python
import sys
import string
import os
import subprocess
import sqlite3
from sqlalchemy import Column, ForeignKey, Integer, String, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import datetime

Base = declarative_base()

class TestResult(Base):
	__tablename__ = 'testResults'
	index = Column(Integer, primary_key=True)
	time = Column(DateTime, default=datetime.datetime.now())
	test_ver = Column(String(20))
	test_type = Column(String(30))
	serial = Column(String(15))
	imei = Column(String(20))
	os_ver = Column(String(50))
	mcu_ver = Column(String(20))
	fpga_ver = Column(String(20))
	asuValue = Column(Integer)
	serialTest = Column(Boolean)
	imeiTest = Column(Boolean)
	versionTest = Column(Boolean)
	ledTest = Column(Boolean)
	sdCardTest = Column(Boolean)
	cellularTest = Column(Boolean)
	canbusTest = Column(Boolean)
	swcTest = Column(Boolean)
	j1708Test = Column(Boolean)
	comTest = Column(Boolean)
	nfcTest = Column(Boolean)
	helpKeyTest = Column(Boolean)
	audioTest = Column(Boolean)
	temperatureTest = Column(Boolean)
	readRTCTest = Column(Boolean)
	accelerometerTest = Column(Boolean)
	gpioTest = Column(Boolean)
	gpioInputsTest = Column(Boolean)
	wiggleTest = Column(Boolean)
	supercapTest = Column(Boolean)
	allPassed = Column(Boolean)
	runTime = Column(Integer)
	
	def getTestResultDict(self):
		returnDict = {}
		returnDict['SerialTest'] = self.serialTest
		returnDict['IMEITest'] = self.imeiTest
		returnDict['VersionTest'] = self.versionTest
		returnDict['LEDTest'] = self.ledTest
		returnDict['SDCardTest'] = self.sdCardTest
		returnDict['CellularTest'] = self.cellularTest
		returnDict['CANBusTest'] = self.canbusTest
		returnDict['SWCTest'] = self.swcTest
		returnDict['J1708Test'] = self.j1708Test
		returnDict['COMTest'] = self.comTest
		returnDict['NFCTest'] = self.nfcTest
		returnDict['HelpKeyTest'] = self.helpKeyTest
		returnDict['AudioTest'] = self.audioTest
		returnDict['TemperatureTest'] = self.temperatureTest
		returnDict['ReadRTCTest'] = self.readRTCTest
		returnDict['AccelerometerTest'] = self.accelerometerTest
		returnDict['GPIOTest'] = self.gpioTest
		returnDict['GPIOInputsTest'] = self.gpioInputsTest
		returnDict['WiggleTest'] = self.wiggleTest
		returnDict['SupercapTest'] = self.supercapTest
		returnDict['AllPassed'] = self.allPassed
		return returnDict

def startSession():
	global session
	engine = create_engine('sqlite:///OBC5Database.db')
	Base.metadata.create_all(engine)
	Base.metadata.bind = engine
	DBSession = sessionmaker(bind=engine)
	session = DBSession()
	#print('Session started')
	
def insertTestResult(testResult):
	session.add(testResult)
	session.commit()
	#print('Test Result Inserted')
	
def getLastInserted():
	lastObject = session.query(TestResult).order_by(TestResult.index.desc()).first()
	return lastObject
	
def commitSession():
	session.commit()
	#print('Session has been commited')

def returnListOfFailures(testDict):
	testResult = getLastInserted()
	testResultDict = testResult.getTestResultDict()
	listOfFailures = []
	
	# This helps sort out tests if they weren't used in our current test_type
	for key in testDict:
		if testResultDict[key] != True:
			#print(key, testResultDict[key])
			listOfFailures.append(key)
	
	return listOfFailures

def updateLastTestResult(column, value):
	testResult = getLastInserted()
	
	# Python doesn't have switch statements?
	if column == 'test_ver':
		testResult.test_ver = value
	elif column == 'test_type':
		testResult.test_type = value
	elif column == 'serial':
		testResult.serial = value
	elif column == 'imei':
		testResult.imei = value
	elif column == 'os_ver':
		testResult.os_ver = value
	elif column == 'mcu_ver':
		testResult.mcu_ver = value
	elif column == 'fpga_ver':
		testResult.fpga_ver = value
	elif column == 'serialTest':
		testResult.serialTest = value
	elif column == 'imeiTest':
		testResult.imeiTest = value
	elif column == 'versionTest':
		testResult.versionTest = value
	elif column == 'ledTest':
		testResult.ledTest = value
	elif column == 'sdCardTest':
		testResult.sdCardTest = value
	elif column == 'cellularTest':
		testResult.cellularTest = value
	elif column == 'asuValue':
		testResult.asuValue = value
	elif column == 'canbusTest':
		testResult.canbusTest = value
	elif column == 'swcTest':
		testResult.swcTest = value
	elif column == 'j1708Test':
		testResult.j1708Test = value
	elif column == 'comTest':
		testResult.comTest = value
	elif column == 'nfcTest':
		testResult.nfcTest = value
	elif column == 'helpKeyTest':
		testResult.helpKeyTest = value
	elif column == 'audioTest':
		testResult.audioTest = value
	elif column == 'temperatureTest':
		testResult.temperatureTest = value
	elif column == 'readRTCTest':
		testResult.readRTCTest = value
	elif column == 'accelerometerTest':
		testResult.accelerometerTest = value
	elif column == 'gpioTest':
		testResult.gpioTest = value
	elif column == 'gpioInputsTest':
		testResult.gpioInputsTest = value
	elif column == 'wiggleTest':
		testResult.wiggleTest = value
	elif column == 'supercapTest':
		testResult.supercapTest = value
	elif column == 'allPassed':
		testResult.allPassed = value
	elif column == 'runTime':
		testResult.runTime = value
	else:
		print('Invalid column selection')
		return
	
	commitSession()
	#print('Updated Test Result:', column, '=', value)
	
def	searchForDuplicates(inputIMEI, inputSerial):
	# Initially no duplicate value
	duplicate = False

	# Check for test results that have the same IMEI but different serial numbers
	for testResult in session.query(TestResult).filter(TestResult.imei == inputIMEI):
		if(testResult.serial != inputSerial):
			duplicate = True

	# Check for test results that have the same Serial but different IMEI numbers
	for testResult in session.query(TestResult).filter(TestResult.serial == inputSerial):
		if(testResult.imei != inputIMEI):
			duplicate = True

	return duplicate

	
	
	
	
	
	
	
	
	
	
