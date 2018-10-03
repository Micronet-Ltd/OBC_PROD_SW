@echo off

@For /F "tokens=*" %%a IN ('"dir /s /a /-c "*.bat"| find "bytes" | find /v "free""') do @Set summaryout=%%a
::@Echo %summaryout%

@For /f "tokens=1,2 delims=)" %%a in ("%summaryout%") do @set filesout=%%a&set sizeout=%%b

@Set sizeout=%sizeout:bytes=%
::@Echo %sizeout%

@Set sizeout=%sizeout: =%
rem @Echo Total Size in (BYTES) :%sizeout%
rem ..\adb shell am broadcast -a com.micronet.obctestingapp.GET_UNLOCK_HASH  --es "fileSize" %sizeout%
..\adb shell am broadcast -a com.micronet.obctestingapp.CHECK_UNLOCK_HASH --es "fileSize" %sizeout% --es "hash" 54185664
