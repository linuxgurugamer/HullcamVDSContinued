
rem @echo off

set H=R:\KSP_1.3.1_dev
set GAMEDIR=HullCameraVDS
set VERSIONFILE=HullcamVDSContinued

echo %H%

copy /Y "%1%2" "..\GameData\%GAMEDIR%\Plugins"
copy /Y %VERSIONFILE%.version ..\GameData\%GAMEDIR%
cd ..
xcopy /y /s /I GameData\%GAMEDIR% "%H%\GameData\%GAMEDIR%"
