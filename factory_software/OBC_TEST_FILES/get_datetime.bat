@echo off

cd testResults

set datetime=
set datetime_file=datetime.txt
if exist datetime.txt del datetime.txt

if /I "%TEST_INFO%"=="RMA" set table=rma_results
if /I "%TEST_INFO%"=="Production" set table=results
if not defined TEST_INFO set table=results

echo select dt from results WHERE test_id = (SELECT MAX(test_id) FROM results); | sqlite3.exe test_results.db > %datetime_file%

set /p datetime=<%datetime_file%
rem echo %datetime%

if exist datetime.txt del datetime.txt

cd ..