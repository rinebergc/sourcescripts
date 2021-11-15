@echo off

set /p "driveLetter=If Steam is installed on the C: drive press enter. Otherwise, enter the correct drive letter now: "
if not defined driveLetter set "driveLetter=C"
set "clientDir=driveLetter:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod"



wmic process where "ExecutablePath='%clientDir:\=\\%'" call terminate
echo "Garry's Mod, if it was running, has been stopped. This will help prevent potential issues while this script runs."



powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"



start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
start /b /wait ROBOCOPY "%temp%\cstrike\cstrike" "%clientDir%\addons\cstrike" "*.vpk"



> "%clientDir%\cfg\mount.cfg" (
	echo "mountcfg"
	echo {
	echo "cstrike"  "%clientDir%\addons\cstrike"
	echo }
)

> "%clientDir%\cfg\mountdepots.txt" (
	echo "gamedepotsystem"
	echo {
	echo "cstrike"  "1"
	echo }
)



del /q %temp%\steamcmd.zip & rmdir /s /q %temp%\steamcmd & rmdir /s /q %temp%\cstrike