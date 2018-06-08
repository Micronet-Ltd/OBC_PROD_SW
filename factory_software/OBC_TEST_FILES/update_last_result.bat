@echo off
rem Update Individual File Result

cd testResults

rem %1 is column
rem %2 is value
set query_file=query.txt
if exist %query_file% del %query_file%

rem Update the latest
@echo UPDATE results SET %1 = %2 WHERE test_id = (SELECT MAX(test_id) FROM results);> %query_file%

sqlite3.exe test_results.db < %query_file%

if exist %query_file% del %query_file%

cd ..