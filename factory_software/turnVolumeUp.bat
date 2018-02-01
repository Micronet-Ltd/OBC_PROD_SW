@echo off
rem Run these commands to adjust the volume on OBC5 devices
adb shell service call audio 4 i32 4 i32 15 i32 0 > nul
adb shell service call audio 4 i32 3 i32 15 i32 0 > nul
adb shell service call audio 4 i32 2 i32 15 i32 0 > nul

rem Tap the home button to hear audible click
adb shell input tap 240 770

echo Volume turned up...