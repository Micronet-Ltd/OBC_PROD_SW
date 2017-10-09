#!/usr/bin/python
import xml.etree.ElementTree as ET


# **********************
#     TestUtil
# **********************

def getConfigurationsDict():
    # Get prompt
    tree = ET.parse('obc_test_files\input\CONFIGURATION.xml')
    root = tree.getroot()
    returnDict = {}

    for child in root:
        returnDict[child.tag] = child.text

    return returnDict


def getConfigurationsDictSoloTest():
    # Get prompt
    tree = ET.parse('input\CONFIGURATION.xml')
    root = tree.getroot()
    returnDict = {}

    for child in root:
        returnDict[child.tag] = child.text

    return returnDict


def readInLanguageFile(language='English'):
    # Get prompt
    tree = ET.parse('obc_test_files\input\LANGUAGE.xml')
    root = tree.getroot()
    returnDict = {}

    for child in root:
        # If type contains what language is set to
        if language == child.get('type'):
            for string in child.iter('text'):
                returnDict[string.get('description')] = string.text

    return returnDict


def readInLanguageFileSoloTest(language='English'):
    # Get prompt
    tree = ET.parse('input\LANGUAGE.xml')
    root = tree.getroot()
    returnDict = {}

    for child in root:
        # If type contains what language is set to
        if language == child.get('type'):
            for string in child.iter('text'):
                returnDict[string.get('description')] = string.text

    return returnDict


def getTestDict():
    configDict = getConfigurationsDict()

    test_choice = configDict['test_type'].strip().lower()

    if test_choice == 'system-a002':
        test_type = 'system-a002'
    elif test_choice == 'system-a001':
        test_type = 'system-a001'
    elif test_choice == 'board':
        test_type = 'board'
    else:
        print(
            'Invalid choice in CONFIGURATION.xml for test type. Should be either \'System-A002\', \'System-A001\', or \'Board\'. Defaulting to System-A002')
        test_type = 'system-a002'

        # Get prompt
    tree = ET.parse('obc_test_files\input\TESTS.xml')
    root = tree.getroot()
    returnDict = {}

    for child in root:
        if child.tag == test_type:
            for test in child:
                returnDict[test.text] = test.get('retry')

    return returnDict


def getLanguageDict():
    configDict = getConfigurationsDict()

    language_choice = configDict['language'].strip().lower()

    if language_choice == 'chinese':
        language = 'Chinese'
    elif language_choice == 'english':
        language = 'English'
    else:
        print(
            'Invalid choice in CONFIGURATION.XML file. Should either be \'English\' or \'Chinese\'. Defaulting to English')
        language = 'English'

    returnDict = readInLanguageFile(language)

    return returnDict


def getLanguageDictSoloTest():
    configDict = getConfigurationsDictSoloTest()

    language_choice = configDict['language'].strip().lower()

    if language_choice == 'chinese':
        language = 'Chinese'
    elif language_choice == 'english':
        language = 'English'
    else:
        print(
            'Invalid choice in CONFIGURATION.XML file. Should either be \'English\' or \'Chinese\'. Defaulting to English')
        language = 'English'

    returnDict = readInLanguageFileSoloTest(language)

    return returnDict
