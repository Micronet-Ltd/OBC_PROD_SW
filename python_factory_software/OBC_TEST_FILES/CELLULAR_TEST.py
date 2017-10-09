#!/usr/bin/python
import subprocess

from colorama import Fore, Style


# **********************
#    Cellular Test
# **********************

def cellularTest(configDict):
    asuLowerBound = int(configDict['asu_lower'])
    asuUpperBound = int(configDict['asu_upper'])

    cmd = '../adb.exe shell dumpsys telephony.registry | grep -i signalstrength'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    list = returnString.split()

    asuValue = int(list[1])

    if asuValue == 99:
        return ('-2', 'ASU value is {} - unknown state'.format(asuValue), asuValue)

    if asuValue < asuLowerBound:
        return ('-1', 'ASU value {} is less than {}'.format(asuValue, asuLowerBound), asuValue)

    if asuValue > asuUpperBound:
        return ('-1', 'ASU value {} is greater than {}'.format(asuValue, asuUpperBound), asuValue)

    return ('1', 'ASU value is {}'.format(asuValue), asuValue)


def retryPrompt(dict):
    retryString = 'Cellular ' + dict['TestFail'] + ' ' + dict['RetryPrompt']

    while True:
        choice = input(retryString)

        if choice.lower() == 'y':
            return True
        elif choice.lower() == 'n':
            return False
        else:
            print('Invalid option. Please select either [Y/N]')


# **********************
#     Main Script
# **********************

def Main(dict, configDict, update=True):
    print()

    continueTesting = True

    data = ()

    while continueTesting == True:
        data = cellularTest(configDict)
        if data[0] == '1':
            continueTesting = False
            break
        else:
            continueTesting = retryPrompt(dict)

    if data[0] == '1':
        print(Fore.GREEN + '** Cellular', dict['TestPassDash'], data[1] + Style.RESET_ALL)
        resultBool = True
    else:
        print(Fore.RED + ' ** Cellular', dict['TestFailDash'], data[1] + Style.RESET_ALL)
        resultBool = False

    if update:
        DBUtil.updateLastTestResult('asuValue', data[2])
        if resultBool:
            DBUtil.updateLastTestResult('cellularTest', True)
        else:
            DBUtil.updateLastTestResult('cellularTest', False)


# If this script is called directly then run the main function
if __name__ == "__main__":
    import DBUtil
    import TestUtil

    langDict = TestUtil.getLanguageDictSoloTest()
    configDict = TestUtil.getConfigurationsDictSoloTest()
    import colorama

    colorama.init()
    Main(langDict, configDict, False)
else:
    import OBC_TEST_FILES.TestUtil as TestUtil
    import OBC_TEST_FILES.DBUtil as DBUtil
