# Get current path. Tried to use $PSScriptRoot but if powershell version is less than 2 is doesn't work
$CURR_DIR = ($pwd).path

# Build the apps and copy them into the factory software folder
#cd .\OBCTestingApp
#cmd.exe /c '\OBCTestingApp\gradlew.bat clean'
#cmd.exe /c '\OBCTestingApp\gradlew.bat build'
#cd ..
#Copy-Item $CURR_DIR\OBCTestingApp\app\build\outputs\apk\release\app-release.apk -Destination $CURR_DIR\factory_software\OBC_TEST_FILES\INSTALL_FILES\obc_testing_app.apk

# Get the version of the test Software
$TEST_VER = @(Get-Content -Path $CURR_DIR\factory_software\OBC_TEST_MAIN.bat | Where-Object {$_ -like 'set test_script_version=*'})[0].split('=')[1]

# Remove old zip if exists for this version
Remove-Item -Path $CURR_DIR\* -include factory_software_v$TEST_VER.zip

# Copy the factory software folder
Copy-Item $CURR_DIR\factory_software -Destination $CURR_DIR\factory_software_v$TEST_VER -Recurse

# Remove files that are not needed
Remove-Item -Path $CURR_DIR\factory_software_v$TEST_VER\* -include Run_Test.bat
Remove-Item -Path $CURR_DIR\factory_software_v$TEST_VER\OBC_TEST_FILES\* -include *.txt
Remove-Item -Path $CURR_DIR\factory_software_v$TEST_VER\OBC_TEST_FILES\testResults\* -include *.txt, *.csv, *.db
Remove-Item -Path $CURR_DIR\factory_software_v$TEST_VER\OBC_TEST_FILES\testResults\settings\* -include *.csv

# Zip up the folder
Compress-Archive -Path $CURR_DIR\factory_software_v$TEST_VER\* -DestinationPath .\factory_software_v$TEST_VER.zip

# Delete copied folder
Remove-Item -Path $CURR_DIR\factory_software_v$TEST_VER -Recurse -Force