## **Using OBC Testing Software v1.2.39**
##### Currently located at http://192.168.1.234:8080/log/software%2FTests%2FOBC_PROD_SW.git/v.1.2.39. 
---
### Updates to Tester Board
  * In order for RS485 to work, the tester board needs to be an Under Dash unit.
    * MCU Version: C.0.6.0 (in the repo)
    * OS Version: TREQr_5_0.1.12.0_20180430.1455
  *	You also need to install the attached APK and start it. This APK returns anything that it receives on RS485.
    * To install it, connect to the device and run:
      * “adb install OBCTesterBoardApp.apk” 
      * “adb shell "am start -n com.micronet.obctesterboardapp/com.micronet.obctesterboardapp.MainActivity"” 
    * Once the app is started once it will start on boot from then on.

### OBC_TEST_MAIN.bat takes three parameters 
*Ex. "OBC_TEST_MAIN.bat System MTR-A002-001 system_tests.dat"*
  * Test_type should either be “System” or “Board”
    * Use “System” if you are testing the whole device. Use “Board” if you are only testing the mcu board. Using “Board” will prompt the user to scan the uut serial number, whereas using “System” will just use the devices serial number. Test_type is stored in the database as well.
  * Device_info is the info/type of the device, ex. “UnderDash”
    * You can use any value for this because it doesn’t impact which tests are run. It is stored in the database.
  * Test_file should be a test .dat file in OBC_TEST_FILES/input/tests folder, ex. “system_tests.dat”
    * The test file you use determines all the tests that will be run. 

### Creating/Editing test .dat files.
  * Test .dat files are located in OBC_TEST_FILES/input/tests.
  * All possible tests are located in that folder in “all_possible_tests.dat”.
  * To edit .dat files, just delete lines or add other tests in.
  * To create test .dat files, just create a new file and add the tests you want to run.
  * Use “install_apps” and “uninstall_apps” to install/uninstall testing apps, it’s important to uninstall apps if you install them.
  * Names of the test .dat files can be anything.
  * Led_ud and audio_ud are tests that only use one led and one speaker.

Here are some example test files:
![Examples of 'test.dat' files](http://192.168.1.234:8080/raw/software/Tests/OBC_PROD_SW.git/v.1.2.39/example_tests.JPG "Examples of 'test.dat' files")
 
### How to use this new setup
To use this new setup, create a new .bat file in the same folder as the OBC_TEST_MAIN.bat file and run the batch file. You can also run these directly from the command line. Here are some examples:

| Filename                    |                                Code                                   |
|-----------------------------|-----------------------------------------------------------------------|
| Board_Test.bat              | call OBC_TEST_MAIN.bat Board NBOARD869V3C board_tests.dat             |
| Board_Smart_Cradle_Test.bat | call OBC_TEST_MAIN.bat Board SmartCradle board_smart_cradle_tests.dat |
| System_Test.bat             | call OBC_TEST_MAIN.bat System MTR-A002-001 system_tests.dat           |
| System_UD_Test.bat          | call OBC_TEST_MAIN.bat System UnderDash system_ud_tests.dat           | 

You can see that the main test is being called along with three parameters as described above. 

### Settings File
The settings file is still the same and is located still at OBC_TEST_FILES/input in “test_options.dat”. Change values to the right of the colons to adjust them.

### Result Files
Result files are still located at OBC_TEST_FILES/testResults. Individual test results are stored in the form of “[SerialNumber].txt”, ex. “4ca55e12.txt”. SerialIMEI.csv stores serial numbers and imei’s of devices tested. Summary.csv is exported from the database and stores all the test results. test_results.db contains all the test results and can be viewed with http://inloop.github.io/sqlite-viewer/. 

### Creating/Adding New Tests
There are a few steps that you must take to create/add a new test. Here are the steps:
  1. Create a name for the test. For example, if you are creating a test that tests ignition, then the test batch file should be named "ignition_test.bat". **Test batch files must always end with "_test.bat".** That is because that is how the test files are called from the .dat test files. For example, when the test sees "audio" in .dat test file then it appends "_test.bat" to it and tries to call that batch file.
  2. Rename or delete the current database that you already have. This is done to avoid conflicts when creating a new database.
  3. Change the database create string to include a new column that stores whether the test passed or failed. For example, with the ignition test, you open create.txt located in \factory_software\OBC_TEST_FILES\testResults\query_strings\ and add a line with "ignition_test boolean," in the place where you want to be located. When the test sees "ignition" in the .dat file then it will run the ignition test batch file and store the result into "ignition_test", so it appends "_test" to it when it stores in the database. **Note that if the test sees a line that ends with "_ud" in the .dat test file then it will have different behavior. For example if it sees "audio_ud" then it will run "audio_ud_test.bat" but then it will remove the "_ud" and store the result in "audio_test" in the database.**  
  4. Add "ignition" to one of the .dat test files and then run the test using the .dat test file.
  