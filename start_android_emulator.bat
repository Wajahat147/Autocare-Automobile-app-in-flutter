@echo off
setlocal
echo ===============================================================
echo   Starting Android Phone Virtual Device (medium_phone)...
echo ===============================================================
echo.

set "PATH=C:\Users\user\AppData\AndroidCLI;C:\Users\user\AppData\Local\Android\Sdk\platform-tools;C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot\bin;%PATH%"
set "JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
set "ANDROID_HOME=C:\Users\user\AppData\Local\Android\Sdk"

call "C:\Users\user\AppData\AndroidCLI\android.exe" emulator start medium_phone
pause
