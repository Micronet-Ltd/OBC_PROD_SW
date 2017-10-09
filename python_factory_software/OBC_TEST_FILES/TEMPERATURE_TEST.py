#!/usr/bin/python
import subprocess

from colorama import Fore, Style


# **********************
#   Temperature Test
# **********************

def tempTest():
    cmd = '../adb.exe shell mctl api 02040A'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    print(returnString)

    returnString = returnString[25:29]
    print(returnString)
    try:
        temperature = int(returnString.strip())
    except ValueError:
        return -1

    temperature = (temperature - 500) / 10

    return temperature


def retryPrompt(dict):
    while True:
        choice = input(dict['TempRetryPrompt'])

        if choice.lower() == 'y':
            return True
        elif choice.lower() == 'n':
            return False
        else:
            print('Invalid option. Please select either [Y/N]')


# **********************
#     Main Script
# **********************

def Main(dict, update=True):
    print()

    continueTesting = True

    while continueTesting == True:
        temp = tempTest()
        if temp == -1:
            continueTesting = retryPrompt(dict)
        else:
            continueTesting = False
            break

    if temp >= 20 and temp <= 50:
        print(Fore.GREEN + '** Temperature', dict['TestPassDash'], '==', temp, Style.RESET_ALL)
        resultBool = True
    else:
        print(Fore.RED + ' ** Temperature', dict['TestFailDash'], 'Expected temperature 20-50c, got', temp,
              Style.RESET_ALL)
        resultBool = False

    if update:
        if resultBool:
            DBUtil.updateLastTestResult('temperatureTest', True)
        else:
            DBUtil.updateLastTestResult('temperatureTest', False)


# If this script is called directly then run the main function	
if __name__ == "__main__":
    import DBUtil
    import TestUtil
    import colorama

    colorama.init()
    langDict = TestUtil.getLanguageDictSoloTest()
    Main(langDict, False)
else:
    import OBC_TEST_FILES.TestUtil as TestUtil
    import OBC_TEST_FILES.DBUtil as DBUtil
