#!/usr/bin/python
import subprocess

from colorama import Fore, Style


# **********************
#   GPIO Inputs Test
# **********************

def gpioTest(dict):
    # GPIO1
    cmd = '../adb.exe shell mctl api 020401'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input1 = int(returnString[24:29].strip())

    # GPIO2
    cmd = '../adb.exe shell mctl api 020402'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input2 = int(returnString[24:29].strip())

    # GPIO3
    cmd = '../adb.exe shell mctl api 020403'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input3 = int(returnString[24:29].strip())

    # GPIO4
    cmd = '../adb.exe shell mctl api 020404'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input4 = int(returnString[24:29].strip())

    # GPIO5
    cmd = '../adb.exe shell mctl api 020405'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input5 = int(returnString[24:29].strip())

    # GPIO6
    cmd = '../adb.exe shell mctl api 020406'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input6 = int(returnString[24:29].strip())

    # GPIO7
    cmd = '../adb.exe shell mctl api 020407'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    input7 = int(returnString[24:29].strip())

    # Ignition
    cmd = '../adb.exe shell mctl api 020400'
    s = subprocess.check_output(cmd.split())
    returnString = s.decode("ascii")

    ignition = int(returnString[24:29].strip())

    returnBool = True

    if not (input1 > 9000 and input1 < 14000):
        returnBool = False
    if not (input2 > 4000 and input2 < 5500):
        returnBool = False
    if not (input3 > 9000 and input3 < 14000):
        returnBool = False
    if not (input4 > 4000 and input4 < 5500):
        returnBool = False
    if not (input5 > 9000 and input5 < 14000):
        returnBool = False
    if not (input6 > 4000 and input6 < 5500):
        returnBool = False
    if not (input7 > 9000 and input7 < 14000):
        returnBool = False
    if not (ignition > 4000 and ignition < 14000):
        returnBool = False

    return (returnBool, (input1, input2, input3, input4, input5, input6, input7, ignition))


def retryPrompt(dict):
    while True:
        inputStr = 'SD Card ' + dict['TestFail'] + '. Can\'t find SD Card. ' + dict['RetryPrompt']
        choice = input(inputStr)

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

    while continueTesting:
        data = gpioTest(dict)
        resultBool = data[0]
        if resultBool:
            continueTesting = False
            break
        else:
            continueTesting = retryPrompt(dict)

    rList = data[1]

    if resultBool:
        print(Fore.GREEN + '** GPIO Inputs', dict['TestPassDash'],
              'input1={} input2={} input3={} input4={} input5={} input6={} input7={} ignition={}'.format(rList[0],
                                                                                                         rList[1],
                                                                                                         rList[2],
                                                                                                         rList[3],
                                                                                                         rList[4],
                                                                                                         rList[5],
                                                                                                         rList[6],
                                                                                                         rList[
                                                                                                             7]) + Style.RESET_ALL)
    else:
        print(Fore.RED + ' ** GPIO Inputs', dict['TestFailDash'],
              'input1={} input2={} input3={} input4={} input5={} input6={} input7={} ignition={}'.format(rList[0],
                                                                                                         rList[1],
                                                                                                         rList[2],
                                                                                                         rList[3],
                                                                                                         rList[4],
                                                                                                         rList[5],
                                                                                                         rList[6],
                                                                                                         rList[
                                                                                                             7]) + Style.RESET_ALL)

    if update:
        if resultBool:
            DBUtil.updateLastTestResult('gpioInputsTest', True)
        else:
            DBUtil.updateLastTestResult('gpioInputsTest', False)


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
