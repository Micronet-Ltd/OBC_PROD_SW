@echo off
rem Update Individual File Result

cd testResults

rem %1 is table
rem %2 is what the column
rem %3 is the value
set query_file=query.txt
if exist %query_file% del %query_file%

rem Update the latest
@echo UPDATE %1 SET %2 = %3 WHERE test_id = (SELECT MAX(test_id) FROM %1);> %query_file%

sqlite3.exe test_results.db < %query_file%

if exist %query_file% del %query_file%

cd ..