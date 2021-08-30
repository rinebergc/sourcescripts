@ECHO OFF

REM Echoing is set to off to limit console flooding.
REM MS Docs: REM records comments in a script, batch, or config.sys file.
REM More information on the ECHO command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/echo.
REM More information on the REM command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rem.


TASKKILL /f /im hl2.exe
ECHO To reduce potential issues while the script is running Garry's Mod (and by extension any hl2.exe based Source game) has been stopped.

REM To reduce potential issues while the script is running Garry's Mod (and by extension any hl2.exe based Source game) has been stopped. 
REM More information on the TASKKILL command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/taskkill.


SET /p "driveLetter=Please enter the letter of the drive your Steam installation is located on: "
IF NOT DEFINED driveLetter SET "driveLetter=C"
SET "clientDir=%driveLetter%:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod"

REM The game library management system Steam can be installed on any lettered drive.
REM Asking the user to specify their install location helps increase script versatility.
REM If the user does not provide input the script will default to the user's C drive.
REM More information on the SET command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1.
REM More information on the IF command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/if.


POWERSHELL -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

REM This script requires the Steam Console Client or SteamCMD, a command-line version of the Steam client, to function.
REM If steamcmd.exe is located in %temp%\steamcmd: the script will continue to run.
REM If steamcmd.zip is located in %temp%: steamcmd.exe will be extracted and the script will continue to run.
REM If neither steamcmd.exe or steamcmd.zip are located in %temp%: steamcmd.zip will be downloaded, steamcmd.exe will be extracted and the script will continue to run.
REM More information on POWERSHELL is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/powershell.
REM More information on the Test-Path cmdlet is available at: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-path?view=powershell-7.1.
REM More information on the Expand-Archive cmdlet is available at: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.1.
REM More information on SteamCMD is available at: https://developer.valvesoftware.com/wiki/SteamCMD.


START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
START /b /wait ROBOCOPY "%temp%\cstrike\cstrike" "%clientDir%\addons\cstrike" "*.vpk"

REM Nesting these actions in START commands allows them to be done synchronously and from the same CMD window.
REM SteamCMD is called to anonymously connect to the Steam network and download Counter-Strike: Source Dedicated Server to %temp%.
REM Because CS:SDS is based on CS:S it contains all the files necessary to enable CS:S support in Garry's Mod.
REM To save disk space once CS:SDS is downloaded only the files required by Garry's Mod are copied, leaving the rest to be deleted during cleanup.
REM More information on the START command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/start.
REM More information on SteamCMD Commands is available at: https://developer.valvesoftware.com/wiki/Command_Line_Options#SteamCMD.
REM More information on Steam Application IDs is available at: https://developer.valvesoftware.com/wiki/Steam_Application_IDs.


(@ECHO "mountcfg" & @ECHO { & @ECHO "cstrike"  "%clientDir%\addons\cstrike" & @ECHO }) > "%clientDir%\cfg\mount.cfg"
(@ECHO "gamedepotsystem" & @ECHO { & @ECHO "cstrike"  "1" & @ECHO }) > "%clientDir%\cfg\mountdepots.txt"

REM Two configuration files are modified/created to enable CS:S content in Garry's Mod.


DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\steamcmd & RMDIR /s /q %temp%\cstrike

REM MS Docs: The temp folder is not automatically emptied and cleanup is the responsibility of the developer using it.
REM Note: Because of Storage sense in Windows 10 this may no longer be true and this could be considered legacy behavior.
REM More information on the DEL command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/del.
REM More information on the RMDIR command is available at: https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/rmdir.
REM More information on Storage sense is available at: https://support.microsoft.com/en-us/windows/manage-drive-space-with-storage-sense-654f6ada-7bfc-45e5-966b-e24aded96ad5.
