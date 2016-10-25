
set H=R:\KSP_1.1.4_dev
echo %H%

set d=%H%
if exist %d% goto one
mkdir %d%
:one
set d=%H%\GameData
if exist %d% goto two
mkdir %d%
:two
set d=%H%\GameData\HullCameraVDS
if exist %d% goto three
mkdir %d%
:three
set d=%H%\GameData\HullCameraVDS\Resources
if exist %d% goto four
mkdir %d%
:four


copy /y bin\Debug\HullCamera.dll ..\GameData\HullCameraVDS\Plugins
copy  /y HullcamVDSContinued.version ..\GameData\HullCameraVDS\HullcamVDSContinued.version

xcopy /Y /E ..\GameData\HullCameraVDS %H%\GameData\HullCameraVDS
copy  ..\HullCameraAssets\Bundles\shaders %H%\GameData\HullCameraVDS\Resources\shaders.bundle

