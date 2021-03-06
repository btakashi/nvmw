@echo off

if not defined NVMW_HOME (
  echo set NVMW_HOME="%~dp0"
  set NVMW_HOME="%~dp0"
)

if not defined PATH_ORG (
  echo set PATH_ORG=%PATH%
  set PATH_ORG=%PATH%
)

if "%1" == "install" (
  call :install %2
  if not %ERRORLEVEL% == 1 call :use %2
) else if "%1" == "use" (
  call :use %2
) else if "%1" == "ls" (
  call :ls
) else (
  call :help
)
exit /b %ERRORLEVEL%

::===========================================================
:: install : Install specified version node and npm
::===========================================================
:install
setlocal

set NODE_VERSION=%1
set NODE_EXE_URL=http://nodejs.org/dist/%NODE_VERSION%/node.exe

echo Start installing Node %NODE_VERSION%

mkdir %NVMW_HOME%\%NODE_VERSION%
set NODE_HOME=%NVMW_HOME%\%NODE_VERSION%
set NODE_EXE_FILE=%NODE_HOME%\node.exe
set PATH=%PATH%;%NODE_HOME%

:: Download node.exe
cscript %NVMW_HOME%\fget.js %NODE_EXE_URL% %NODE_EXE_FILE%
if not exist %NODE_EXE_FILE% (
   echo Download %NODE_EXE_FILE% from %NODE_EXE_URL% failed
   rd /Q /S %NODE_HOME%
   endlocal
   exit /b 1
) else (
    :: Install npm
    echo Start install npm
    cmd /c git config --system http.sslcainfo /bin/curl-ca-bundle.crt
    cmd /c git clone --recursive git://github.com/isaacs/npm.git %NODE_HOME%\npm
    cmd /c node %NODE_HOME%\npm\cli.js install npm -gf

    echo Finished
    endlocal
    exit /b 0
)

::===========================================================
:: use : Change current version
::===========================================================
:use
setlocal
set NODE_VERSION=%1
set NODE_HOME=%NVMW_HOME%\%NODE_VERSION%

if not exist %NODE_HOME% (
  echo Node %NODE_VERSION% is not installed
  exit /b 1
)

endlocal

echo Use Node %1
set NVMW_CURRENT=%1
set PATH=%PATH_ORG%;%NVMW_HOME%\%1
exit /b 0

::===========================================================
:: ls : List installed versions
::===========================================================
:ls
setlocal
dir %NVMW_HOME%\v* /b /ad
if "%NVMW_CURRENT%" == "" (
  set NVMW_CURRENT_V=none
) else (
  set NVMW_CURRENT_V=%NVMW_CURRENT%
)
echo Current: %NVMW_CURRENT_V%
endlocal
exit /b 0

::===========================================================
:: help : Show help message
::===========================================================
:help
echo;
echo Node Version Manager for Windows
echo;
echo Usage:
echo   nvmw help                    Show this message
echo   nvmw install [version]       Download and install a [version]
echo   nvmw use [version]           Modify PATH to use [version]
echo   nvmw ls                      List installed versions
echo;
echo Example:
echo   nvmw install v0.6.0          Install a specific version number
echo   nvmw use v0.6.0              Use the specific version
exit /b 0
