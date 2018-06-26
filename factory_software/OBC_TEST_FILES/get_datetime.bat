@echo off

cd testResults

set datetime=
set datetime_file=datetime.txt
if exist datetime.txt del datetime.txt

sqlite3.exe test_results.db < query_strings\getDatetime.txt

set /p datetime=<%datetime_file%
rem echo %datetime:"=%

cd ..