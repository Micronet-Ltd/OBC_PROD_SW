@echo off
rem Insert New Result

cd testResults

rem %1 is table
rem %2 is test version
rem %3 is device type
set query_file=query.txt
if exist %query_file% del %query_file%

rem Update the latest
@echo INSERT INTO %1 DEFAULT VALUES;> %query_file%

sqlite3.exe test_results.db < %query_file%

if exist %query_file% del %query_file%

cd ..