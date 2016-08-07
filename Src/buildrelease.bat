@echo off
set DEFHOMEDRIVE=d:
set DEFHOMEDIR=%DEFHOMEDRIVE%%HOMEPATH%
set HOMEDIR=
set HOMEDRIVE=%CD:~0,2%

set RELEASEDIR=d:\Users\jbb\release
set ZIP="c:\Program Files\7-zip\7z.exe"
echo Default homedir: %DEFHOMEDIR%

set /p HOMEDIR= "Enter Home directory, or <CR> for default: "

if "%HOMEDIR%" == "" (
set HOMEDIR=%DEFHOMEDIR%
)
echo %HOMEDIR%

SET _test=%HOMEDIR:~1,1%
if "%_test%" == ":" (
set HOMEDRIVE=%HOMEDIR:~0,2%
)

type HullcamVDSContinued.version
set /p VERSION= "Enter version: "

set d=%HOMEDIR\install
if exist %d% goto one
mkdir %d%
:one
set d=%HOMEDIR%\install\Gamedata
if exist %d% goto two
mkdir %d%
:two

rmdir /s /q %HOMEDIR%\install\Gamedata\HullCameraVDS

copy bin\Release\HullCamera.dll ..\GameData\HullCameraVDS\Plugins
copy  HullcamVDSContinued.version ..\GameData\HullCameraVDS\HullcamVDSContinued.version

xcopy /Y /E ..\GameData\HullCameraVDS  %HOMEDIR%\install\Gamedata\HullCameraVDS\
copy /y ../LICENSE %HOMEDIR%\install\Gamedata\HullCameraVDS
copy /y ..\GameData\ModuleManager*.dll %HOMEDIR%\install\GameData

%HOMEDRIVE%
cd %HOMEDIR%\install

set FILE="%RELEASEDIR%\HullCameraVDS-%VERSION%.zip"
IF EXIST %FILE% del /F %FILE%
%ZIP% a -tzip %FILE% GameData\HullCameraVDS  GameData\ModuleManager*.*
