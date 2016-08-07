
set H=R:\KSP_1.1.3_dev
echo %H%

set d=%H%
if exist %d% goto one
mkdir %d%
:one
set d=%H%\Gamedata
if exist %d% goto two
mkdir %d%
:two




copy /y bin\Debug\HullCamera.dll ..\GameData\HullCameraVDS\Plugins
copy  /y HullcamVDSContinued.version ..\GameData\HullCameraVDS\HullcamVDSContinued.version

xcopy /Y /E ..\GameData\HullCameraVDS %H%\GameData\HullCameraVDS

