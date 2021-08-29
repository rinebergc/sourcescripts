@ECHO OFF
SET "installDir=C:\garrysmod\srcds"
SET "repoScheme=%temp%\sourcescripts\sourcescripts-main"

REM Reduce code complexity by adding commonly referenced locations to a variable.


POWERSHELL -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"
POWERSHELL -command "(New-Object Net.WebClient).DownloadFile('https://github.com/rinebergc/sourcescripts/archive/refs/heads/main.zip','%temp%\sourcescripts.zip'); Expand-Archive -LiteralPath %temp%\sourcescripts.zip -DestinationPath %temp%\sourcescripts"

REM Download steamCMD and the latest config files from Github.


START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_installDir %installDir% +app_update 4020 validate +quit
  START /b /wait ROBOCOPY /s "%repoScheme%\addons" "%installDir%\garrysmod\addons"
  START /b /wait ROBOCOPY /s "%repoScheme%\data" "%installDir%\garrysmod\data"
  START /b /wait ROBOCOPY /s "%repoScheme%\cfg" "%installDir%\garrysmod\cfg"
  START /b /wait ROBOCOPY "%installDir%\garrysmod\gamemodes\sandbox\entities\entities" "%installDir%\garrysmod\gamemodes\terrortown\entities\entities" "base_gmodentity.lua"
  START /b /wait ROBOCOPY "%installDir%\garrysmod\gamemodes\base\entities\weapons\weapon_base" "%installDir%\garrysmod\gamemodes\terrortown\entities\weapons\functions" "shared.lua"

REM Download the Source server for Garry's Mod, import configuration files, and reduce addon related errors by preaddressing missing entities. 


(@ECHO start srcds.exe -console -game garrysmod +gamemode GAMEMODE +sv_setsteamaccount GSLTOKEN +host_workshop_collection COLLECTIONID +map MAP +maxplayers ##) > "%installDir%\launcher_ttt.bat"

REM Create a script to launch the Garry's Mod server with launch options configured. 
REM A GSL Token for sv_setsteamaccount can be obtained @ https://steamcommunity.com/dev/managegameservers.


DEL /q %temp%\sourcescripts.zip & DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\sourcescripts & RMDIR /s /q %temp%\steamcmd

REM MS Docs: The temp folder is not managed by Windows and it is the responsibility of the developer using it to clean up after themselves.
REM This may no longer be true in Windows 10.
