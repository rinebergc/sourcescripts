@echo off
set "srcds=C:\garrysmod\srcds"

rem Comments have been added to provide clarity and educational value where possible.
rem For more information on Powershell cmdlets see: https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1.
rem For more information on SteamCMD see: https://developer.valvesoftware.com/wiki/SteamCMD, https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD, and https://developer.valvesoftware.com/wiki/Steam_Application_IDs.
rem For more information on Windows commands see: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands.

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



powershell -command "(New-Object Net.WebClient).DownloadFile('!CONFIGREPO!','%temp%\main.zip'); Expand-Archive -LiteralPath %temp%\main.zip -DestinationPath %temp%\main"
rem Download config files from Github.



start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_installDir %installDir% +app_update 4020 validate +quit
  start /b /wait robocopy /s "%temp%\main\!CONFIGREPO!-main\addons" "%srcds%\garrysmod\addons"
  start /b /wait robocopy /s "%temp%\main\!CONFIGREPO!-main\data" "%srcds%\garrysmod\data"
  start /b /wait robocopy /s "%temp%\main\!CONFIGREPO!-main\cfg" "%srcds%\garrysmod\cfg"
  start /b /wait robocopy "%srcds%\garrysmod\gamemodes\sandbox\entities\entities" "%srcds%\garrysmod\gamemodes\terrortown\entities\entities" "base_gmodentity.lua"
  start /b /wait robocopy "%srcds%\garrysmod\gamemodes\base\entities\weapons\weapon_base" "%srcds%\garrysmod\gamemodes\terrortown\entities\weapons\functions" "shared.lua"
rem Download srcds for Garry's Mod, import configuration files, and preaddressing missing entity errors. 



> "%srcds%\launcher_ttt.bat" (
	echo start srcds.exe -console -game garrysmod +gamemode !GAMEMODE! +sv_setsteamaccount !GSLTOKEN! +host_workshop_collection !COLLECTIONID! +map !MAP! +maxplayers !NUM!
)
rem Create a script to launch the Garry's Mod server with launch options configured. 
rem A GSL Token for sv_setsteamaccount can be obtained @ https://steamcommunity.com/dev/managegameservers.



del /q %temp%\main.zip & rmdir /s /q %temp%\main
del /q %temp%\steamcmd.zip & rmdir /s /q %temp%\steamcmd
rem Cleanup - Remove temporary files and directories.
