@echo off

if exist system_summary.csv del system_summary.csv
if exist board_summary.csv del board_summary.csv

sqlite3.exe test_results.db < query_strings\export.txt