@echo off
setlocal
echo ===============================================================
echo   Launching AutoCare Automobile App with Mobile Preview...
echo ===============================================================
echo.

set "PATH=C:\Users\user\development\flutter\bin;C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot\bin;C:\Users\user\AppData\Local\Android\Sdk\platform-tools;%PATH%"
set "JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
set "ANDROID_HOME=C:\Users\user\AppData\Local\Android\Sdk"

cd /d "%~dp0"
call "C:\Users\user\development\flutter\bin\flutter.bat" run -d chrome
pause
