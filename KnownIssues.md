## Known Issues
--------
|Index|Issue|Description|
|---|----|------|
|1| J1708 Retry Failures | If the J1708 test is run and then the test is stopped and restarted without rebooting the device then J1708 will fail. |
|2| Audio Test Failures | Sometimes the audio test will fail because both speakers get shut off instead of just one.|
|3| Different Times | Different times are reported on the individual serial.txt files than in the summary file. This happens because the individual results use the batch %TIME% while the summary file uses sqlite3's default datetime. |