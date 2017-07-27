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
	test_ver = Column(String(10))
	test_type = Column(String(30))
	serial = Column(String(15))
	imei = Column(String(20))
	os_ver = Column(String(30))
	mcu_ver = Column(String(20))
	fpga_ver = Column(String(20))
	serialTest = Column(Boolean)
	imeiTest = Column(Boolean)
	versionTest = Column(Boolean)
	ledTest = Column(Boolean)
	sdCardTest = Column(Boolean)
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
	gpInputsOnlyTest = Column(Boolean)
	wiggleTest = Column(Boolean)
	supercapTest = Column(Boolean)
	allPassed = Column(Boolean)
	
	
	
	

def startSession():
	global session
	
	engine = create_engine('sqlite:///OBC5Database.db')
	
	Base.metadata.create_all(engine)
	
	Base.metadata.bind = engine
	
	DBSession = sessionmaker(bind=engine)
	
	session = DBSession()
	
	print('Session started')
	
def insertTestResult(testResult):
	session.add(testResult)
	session.commit()
	print('Test Result Inserted')
	
def getLastInserted():
	lastObject = session.query(TestResult).order_by(TestResult.index.desc()).first()
	return lastObject
	
def commitSession():
	session.commit()
	print('Session has been commited')
	
	
