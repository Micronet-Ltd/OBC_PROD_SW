@echo off

cd testResults

sqlite3.exe test_results.db < query_strings\create.txt

cd ..