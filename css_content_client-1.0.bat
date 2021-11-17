@echo off

rem Comments have been added to provide clarity and educational value where possible.
rem For more information on Powershell cmdlets see: https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1
rem For more information on SteamCMD see: https://developer.valvesoftware.com/wiki/SteamCMD, https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD, and https://developer.valvesoftware.com/wiki/Steam_Application_IDs.
rem For more information on Windows commands see: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands



set "folderPicker="(new-object -COM 'Shell.Application').BrowseForFolder(0,'Please select your GarrysMod client directory. Typically: This PC\Local Disk (C:)\Program Files (x86)\Steam\steamapps\common\GarrysMod.',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell -command %folderPicker%`) do set "clientDir=%%I"
rem Prompt the user to select their Garry's Mod directory rather than assume where it's installed.



set steamcmdCheck= ^
if (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) { ^
} elseif (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) { ^
	Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd ^
} elseif (Test-Path -Path %temp%\steamcmd.exe -PathType leaf) { ^
	if (-not (Test-Path -Path %temp%\steamcmd -PathType container)) {New-Item -ItemType directory -Path %temp%\steamcmd} ^
	Move-Item -Path %temp%\steamcmd.exe -Destination %temp%\steamcmd\steamcmd.exe ^
} else { ^
	(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); ^
	Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd ^
}
powershell -command "%steamcmdCheck%"
rem This script requires SteamCMD to function. Check for it and continue if it's present. Otherwise, download it.



start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\steamcmd\cstrike +app_update 232330 validate +quit
start /b /wait robocopy "%temp%\steamcmd\cstrike\cstrike" "%clientDir%\garrysmod\addons\cstrike" "*.vpk"
rem Download the Counter-Strike: Source Dedicated Server to %temp%\cstrike using steamCMD.
rem The dedicated server includes the content, stored as .vpk's, required by Garry's Mod. To save disk space only these files are copied.



wmic process where "ExecutablePath='%clientDir:\=\\%\\hl2.exe'" call terminate
echo "Garry's Mod, if it was running, has been stopped. This will help prevent potential issues while this script runs."
> "%clientDir%\garrysmod\cfg\mount.cfg" (
	echo "mountcfg"
	echo {
	echo "cstrike"  "%clientDir%\garrysmod\addons\cstrike"
	echo }
)
> "%clientDir%\garrysmod\cfg\mountdepots.txt" (
	echo "gamedepotsystem"
	echo {
	echo "cstrike"  "1"
	echo }
)
rem Kill Garry's Mod, if it's running, and edit mount/mountdepots.cfg to mount the newly downloaded content.



del /q %temp%\steamcmd.zip & rmdir /s /q %temp%\steamcmd
rem Cleanup - Remove temporary files and directories.
