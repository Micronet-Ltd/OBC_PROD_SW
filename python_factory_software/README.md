Python OBC Testing Software

This structure is a work in progress and will most likely be changed and improved.

What is included in this folder:

    - A zip file that contains python version 3.5.4 that you will need to unzip to use.
    - A batch file "OBC_TEST.bat" that will start the python test. (This is because the python.exe file is a folder down so this makes it easier to start and run. This will most likely definitely be changed)
    - A folder "OBC_TEST_FILES" that contains the python scripts, the database, and a folder "input" that contains the xml files that for test configuration, language, and type and also a folder "INSTALL_FILES" that contains the apks to be installed and other test files.
    - The ADB exe and its corresponding DLLs.

The database can be viewed a in a few ways, but currently I find the easiest way to use an online sqlite database viewer for testing.

The three xml configuration files are used to select which tests you are using, which language, and which other test options.

