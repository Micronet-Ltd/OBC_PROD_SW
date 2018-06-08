@echo off
rem Insert New Result

cd testResults

set query_file=query.txt
if exist %query_file% del %query_file%

rem Update the latest
@echo INSERT INTO results DEFAULT VALUES;> %query_file%

sqlite3.exe test_results.db < %query_file%

if exist %query_file% del %query_file%

cd ..