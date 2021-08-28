@ECHO OFF
SET client_dir=C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod

powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
START /b /wait ROBOCOPY "%temp%\cstrike\cstrike" "%client_dir%\addons\cstrike" "*.vpk"

(@ECHO "mountcfg" & @ECHO { & @ECHO "cstrike"  "%client_dir%\addons\cstrike" & @ECHO }) > "%client_dir%\cfg\mount.cfg"
(@ECHO "gamedepotsystem" & @ECHO { & @ECHO "cstrike"  "1" & @ECHO }) > "%client_dir%\cfg\mountdepots.txt"

DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\steamcmd & RMDIR /s /q %temp%\cstrike