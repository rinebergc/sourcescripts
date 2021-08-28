@ECHO OFF
SET install_dir=C:\garrysmod\srcds

REM GSL Token for sv_setsteamaccount can be found @ https://steamcommunity.com/dev/managegameservers

powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %install_dir% +app_update 4020 validate +quit
  START /b /wait ROBOCOPY /s "%CD%\addons" "%install_dir%\garrysmod\addons"
  START /b /wait ROBOCOPY /s "%CD%\data" "%install_dir%\garrysmod\data"
  START /b /wait ROBOCOPY /s "%CD%\cfg" "%install_dir%\garrysmod\cfg"
  START /b /wait ROBOCOPY "%install_dir%\garrysmod\gamemodes\sandbox\entities\entities" "%install_dir%\garrysmod\gamemodes\terrortown\entities\entities" "base_gmodentity.lua"
  START /b /wait ROBOCOPY "%install_dir%\garrysmod\gamemodes\base\entities\weapons\weapon_base" "%install_dir%\garrysmod\gamemodes\terrortown\entities\weapons\functions" "shared.lua"

(@ECHO start srcds.exe -console -game garrysmod +gamemode terrortown +sv_setsteamaccount ***REMOVED*** +host_workshop_collection ***REMOVED*** +map gm_construct +maxplayers 24) > "%install_dir%\launcher_ttt.bat"
REM powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\desktop\launcher_ttt.lnk');$s.TargetPath='%install_dir%\launcher_ttt.bat';$s.Save()"

DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\steamcmd