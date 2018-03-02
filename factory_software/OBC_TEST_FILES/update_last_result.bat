@echo off
rem Update Individual File Result

cd testResults

rem %1 is column
rem %2 is value
rem %3 is optional table to write to
set query_file=query.txt
if exist %query_file% del %query_file%

set table=
if /I "%TEST_TYPE%"=="System" set table=system_results
if /I "%TEST_TYPE%"=="Board" set table=board_results
if not "%3"=="" set table=%3

rem Update the latest
@echo UPDATE %table% SET %1 = %2 WHERE test_id = (SELECT MAX(test_id) FROM %table%);> %query_file%

sqlite3.exe test_results.db < %query_file%

if exist %query_file% del %query_file%

cd ..