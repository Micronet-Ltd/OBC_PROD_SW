#!/usr/bin/python
import os
import subprocess
import time


# **********************
#    Install Files
# **********************

def Main():
    with open(os.devnull, 'w') as nul:
        cmd = '../adb install -r INSTALL_FILES/obc_testing_app.apk'
        s = subprocess.check_output(cmd.split(), stderr=nul)

    cmd = '../adb shell am start -n com.micronet.obctestingapp/com.micronet.obctestingapp.MainActivity'
    s = subprocess.check_output(cmd.split())

    with open(os.devnull, 'w') as nul:
        cmd = '../adb install -r INSTALL_FILES/nfc_test.apk'
        s = subprocess.check_output(cmd.split(), stderr=nul)

    cmd = '../adb shell am start -n \'me.davidvassallo.nfc/me.davidvassallo.nfc.MainActivity\' -a android.intent.action.MAIN -c android.intent.category.LAUNCHER'
    s = subprocess.check_output(cmd.split())

    time.sleep(3)


# If this script is called directly then run the main function	
if __name__ == "__main__":
    # print("Install Files is being called directly")
    Main()
