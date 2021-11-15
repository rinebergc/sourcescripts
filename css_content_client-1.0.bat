@echo off

rem Comments have been added to provide clarity and educational value where possible.
rem
rem echo: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/echo.
rem rem: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rem.



set /p "driveLetter=If Steam is installed on the C: drive press enter. Otherwise, enter the correct drive letter now: "
if not defined driveLetter set "driveLetter=C"
set "clientDir=driveLetter:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod"

rem Increase this scripts versatility by allowing the user to specify the drive their Steam client is installed to.
rem
rem set: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1.
rem if: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/if.



wmic process where "ExecutablePath='%clientDir:\=\\%\\hl2.exe'" call terminate
echo "Garry's Mod, if it was running, has been stopped. This will help prevent potential issues while this script runs."

rem wmic: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/wmic.
rem call: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/call.



powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

rem This script requires SteamCMD to function. Check for it in %temp% and %temp%\steamcmd. Continue if it's present. Otherwise, download it.
rem
rem powershell: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/powershell.
rem test-path: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.1.
rem expand-archive: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.1.
rem steamcmd: https://developer.valvesoftware.com/wiki/SteamCMD.



start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
start /b /wait ROBOCOPY "%temp%\cstrike\cstrike" "%clientDir%\addons\cstrike" "*.vpk"

rem Download the Counter-Strike: Source Dedicated Server to %temp%\cstrike using steamCMD.
rem The dedicated server includes the content, stored as .vpk's, required by Garry's Mod. To save disk space only these files are copied.
rem
rem start: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/start.
rem steamcmd commands: https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD.
rem steam application ids: https://developer.valvesoftware.com/wiki/Steam_Application_IDs.



> "%clientDir%\cfg\mount.cfg" (
	echo "mountcfg"
	echo {
	echo "cstrike"  "%clientDir%\addons\cstrike"
	echo }
)
rem Alternative: (echo "mountcfg" & ECHO { & echo "cstrike"  "%clientDir%\addons\cstrike" & echo }) > "%clientDir%\cfg\mount.cfg"

> "%clientDir%\cfg\mountdepots.txt" (
	echo "gamedepotsystem"
	echo {
	echo "cstrike"  "1"
	echo }
)
rem Alternative: (echo "gamedepotsystem" & echo { & echo "cstrike"  "1" & echo }) > "%clientDir%\cfg\mountdepots.txt"

rem Configure Garry's Mod to mount the newly downloaded content.



del /q %temp%\steamcmd.zip & rmdir /s /q %temp%\steamcmd & rmdir /s /q %temp%\cstrike

rem Clean up the temp files. It's up to the developer to manage their usage of the %temp% folder. Storage Sense in Windows 10+ may mean this is no longer be true.
rem
rem del: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/del.
rem rmdir: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rmdir.
rem storage sense: https://support.microsoft.com/en-us/windows/manage-drive-space-with-storage-sense-654f6ada-7bfc-45e5-966b-e24aded96ad5.
