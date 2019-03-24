rem Time:2019.1.15
rem Author:LuYanjie
rem Company:NanFangDianWang
rem File:check_win_host.bat
rem Version:1.0
rem Description:check linux system

@echo off
for /f "skip=2 tokens=2 delims=," %%i in ('wmic os get FreePhysicalMemory /format:CSV') do (
set richparm2=%%i&goto e1)
:e1
for /f "skip=2 tokens=2 delims=," %%i in ('wmic os get TotalVisibleMemorySize /format:CSV') do (
set richparm3=%%i&goto e2)
:e2
set /a richparm2=%richparm2%/1024
set /a richparm3=%richparm3%/1024
echo Memory Free Size:%richparm2% MB,Memory Total Size:%richparm3% MB

rem set var=Hell

call:myDosFunc
goto:eof

:myDosFunc    - here starts my function identified by it`s label
echo.  here the myDosFunc function is executing a group of commands
echo.  it could do a lot of things
goto:eof
