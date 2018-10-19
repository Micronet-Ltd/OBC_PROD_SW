@echo off
rem Insert New Result

cd testResults

if /I "%TEST_INFO%"=="RMA" set table=rma_results
if /I "%TEST_INFO%"=="Production" set table=results
if not defined TEST_INFO set table=results

rem Insert a new row into the correct table
echo insert into %table% default values; | sqlite3.exe test_results.db 

cd ..