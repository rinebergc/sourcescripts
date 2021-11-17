@echo off

rem Comments have been added to provide clarity and educational value where possible.
rem echo: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/echo.
rem rem: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rem.



set "folderPicker="(new-object -COM 'Shell.Application').BrowseForFolder(0,'Please select your GarrysMod client directory. Typically: This PC\Local Disk (C:)\Program Files (x86)\Steam\steamapps\common\GarrysMod.',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell %folderPicker%`) do set "clientDir=%%I"

rem for: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/for.
rem set: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1.



wmic process where "ExecutablePath='%clientDir:\=\\%\\hl2.exe'" call terminate
echo "Garry's Mod, if it was running, has been stopped. This will help prevent potential issues while this script runs."

rem call: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/call.
rem wmic: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/wmic.



powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

rem This script requires SteamCMD to function. Check for it in %temp% and %temp%\steamcmd. Continue if it's present. Otherwise, download it.
rem expand-archive: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.1.
rem powershell: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/powershell.
rem steamcmd: https://developer.valvesoftware.com/wiki/SteamCMD.
rem test-path: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.1.



start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
start /b /wait robocopy "%temp%\cstrike\cstrike" "%clientDir%\garrysmod\addons\cstrike" "*.vpk"

rem Download the Counter-Strike: Source Dedicated Server to %temp%\cstrike using steamCMD.
rem The dedicated server includes the content, stored as .vpk's, required by Garry's Mod. To save disk space only these files are copied.
rem start: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/start.
rem steamcmd commands: https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD.
rem steam application ids: https://developer.valvesoftware.com/wiki/Steam_Application_IDs.



rem Alternative: (echo "mountcfg" & ECHO { & echo "cstrike"  "%clientDir%\garrysmod\addons\cstrike" & echo }) > "%clientDir%\garrysmod\cfg\mount.cfg"
> "%clientDir%\garrysmod\cfg\mount.cfg" (
	echo "mountcfg"
	echo {
	echo "cstrike"  "%clientDir%\garrysmod\addons\cstrike"
	echo }
)

rem Alternative: (echo "gamedepotsystem" & echo { & echo "cstrike"  "1" & echo }) > "%clientDir%\garrysmod\cfg\mountdepots.txt"
> "%clientDir%\garrysmod\cfg\mountdepots.txt" (
	echo "gamedepotsystem"
	echo {
	echo "cstrike"  "1"
	echo }
)

rem Configure Garry's Mod to mount the newly downloaded content.



del /q %temp%\steamcmd.zip & rmdir /s /q %temp%\steamcmd & rmdir /s /q %temp%\cstrike

rem del: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/del.
rem rmdir: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rmdir.
