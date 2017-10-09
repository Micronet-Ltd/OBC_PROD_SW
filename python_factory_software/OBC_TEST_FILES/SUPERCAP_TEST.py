#!/usr/bin/python
import msvcrt
import os
import subprocess
import sys
import time

from colorama import Fore, Style


# **********************
#    Supercap Test
# **********************

def supercapTest(dict):
    # ---------- UPDATE HOTSPOT POWERLOSS SETTING ----------
    # Change the default of wi-fi off during power loss
    cmd = '../adb.exe shell chmod 666 /sys/class/hwmon/hwmon1/wlan_off_delay'
    s = subprocess.check_output(cmd.split())
    cmd = '../adb.exe shell echo 17000 > /sys/class/hwmon/hwmon1/wlan_off_delay'
    s = subprocess.check_output(cmd.split())

    # ---------- CHECK IF SUPERCAP CHARGING ----------
    cmd = '../adb.exe shell mctl api 020409'
    s = subprocess.check_output(cmd.split())
    supercapVoltage = s.decode("ascii")
    # print(supercapVoltage)
    supercapVoltage = int(supercapVoltage[24:29])
    # print(supercapVoltage)

    # Verify supercap is charged but not over charged
    if supercapVoltage < 3000 or supercapVoltage > 5500:
        return (-1, (supercapVoltage))  # SC_LEVEL_ERROR

    # ---------- CHECK INPUT VOLTAGE LEVEL ----------
    # Export the gpio
    cmd = '../adb.exe shell echo 991 > /sys/class/gpio/export'
    s = subprocess.check_output(cmd.split())

    # Read initial input power voltage
    cmd = '../adb.exe shell mctl api 020408'
    s = subprocess.check_output(cmd.split())
    powerInVoltageOn = s.decode("ascii")
    # print(powerInVoltageOn)
    powerInVoltageOn = int(powerInVoltageOn[24:29])
    # print(powerInVoltageOn)

    # ---------- PROMPT USER TO REMOVE POWER ----------

    print(dict['SCPrompt'])
    # Wait for any character to be pressed. Redirect output stream temporarily.
    save_stdout = sys.stdout
    with open(os.devnull, 'w') as nul:
        sys.stdout = nul
        msvcrt.getch()
    sys.stdout = save_stdout

    # 2 sec delay added after the device is switched off incase the user presses any key before disconnecting power
    # It also takes 2 seconds of power loss before the power loss GPIO is toggled by the MCU
    time.sleep(2)

    # ---------- MAKE SURE DEVICE IS UNPLUGGED ----------

    # Read input power voltage after power is removed (running on supercap)
    cmd = '../adb.exe shell mctl api 020408'
    s = subprocess.check_output(cmd.split())
    powerInVoltageOff = s.decode("ascii")

    # print(powerInVoltageOff)

    index = powerInVoltageOff.find('voltage =') + 10
    endIndex = powerInVoltageOff.find('mV')

    # print(powerInVoltageOff[index:endIndex])

    powerInVoltageOff = int(powerInVoltageOff[index:endIndex])
    # Verify input voltage is off
    if powerInVoltageOff > 8000:
        return (-2, (supercapVoltage, powerInVoltageOn, powerInVoltageOff))  # VIN_LEVEL_ERROR

    supercapPass = False

    # ---------- START LOOP FOR POWERLOSS NOTIFICATION ----------

    for i in range(15):
        with open(os.devnull, 'w') as nul:
            cmd = '../adb.exe shell mctl api 020409'
            s = subprocess.check_output(cmd.split(), stderr=nul)
            supercapVoltageOff = s.decode("ascii")

            # print(supercapVoltageOff)

            index = supercapVoltageOff.find('voltage =') + 10
            endIndex = supercapVoltageOff.find('mV')

            supercapVoltageOff = int(supercapVoltageOff[index:endIndex])

            # print(supercapVoltageOff)

            cmd = '../adb.exe shell cat /sys/class/gpio/gpio991/value'
            s = subprocess.check_output(cmd.split(), stderr=nul)
            powerLoss = s.decode("ascii")

            # print(powerLoss)

            powerLoss = int(powerLoss)

            if powerLoss == 1:
                supercapPass = True
                # print('Powerloss detected')
                break

    if not supercapPass:
        return (-3, (supercapVoltage, powerInVoltageOn, powerInVoltageOff, supercapVoltageOff))  # POWER_LOSS_ERROR
    else:
        return (1, (supercapVoltage, powerInVoltageOn, powerInVoltageOff, supercapVoltageOff))  # PASS


# **********************
#     Main Script
# **********************

def Main(dict, update=True):
    print()

    data = supercapTest(dict)

    if data[0] == 1:
        print(Fore.GREEN + '** Supercap', dict['TestPassDash'] + Style.RESET_ALL)
        resultBool = True
    elif data[0] == -1:
        print(Fore.RED + ' ** Supercap', dict['TestFailDash'],
              'initial SuperCap voltage not in range - SC_LEVEL_ERROR' + Style.RESET_ALL)
        resultBool = False
    elif data[0] == -2:
        print(Fore.RED + ' ** Supercap', dict['TestFailDash'],
              'input voltage too high in supercap mode - VIN_LEVEL_ERROR' + Style.RESET_ALL)
        resultBool = False
    elif data[0] == -3:
        print(Fore.RED + ' ** Supercap', dict['TestFailDash'],
              'didn\'t get power loss notification - POWER_LOSS_ERROR' + Style.RESET_ALL)
        resultBool = False

    length = len(data[1])

    print('                    Supercap on voltage :', data[1][0])
    if length == 4:
        print('                    Supercap off voltage :', data[1][3])
    if length >= 2:
        print('                    Input on voltage :', data[1][1])
    if length >= 3:
        print('                    Input off voltage :', data[1][2])

    if update:
        if resultBool:
            DBUtil.updateLastTestResult('supercapTest', True)
        else:
            DBUtil.updateLastTestResult('supercapTest', False)


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
