@ECHO OFF

REM MS Docs: REM records comments in a script, batch, or config.sys file.
REM Echoing is set to off to limit console flooding.


SET /p "driveLetter=Please enter the letter of the drive on which your Steam installation is located: "
IF NOT DEFINED driveLetter SET "driveLetter=C"
SET "clientDir=%driveLetter%:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod"

REM The game library management system Steam can be installed on any lettered drive.
REM Asking the user to specify their install location helps increase script versatility.
REM If the user does not provide input the script will default to the user's C drive.


POWERSHELL -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

REM This script requires the Steam Console Client or SteamCMD, a command-line version of the Steam client, to function.
REM If steamcmd.exe is located in %temp%\steamcmd the script will continue to run.
REM If steamcmd.zip is located in %temp% steamcmd.exe will be extracted and the script will continue to run.
REM If neither steamcmd.exe or steamcmd.zip are located in %temp% steamcmd.zip will be downloaded, steamcmd.exe will be extracted and the script will continue to run.


START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %temp%\cstrike +app_update 232330 validate +quit
START /b /wait ROBOCOPY "%temp%\cstrike\cstrike" "%clientDir%\addons\cstrike" "*.vpk"

REM SteamCMD is called to download Counter Strike: Source resources to the user's Garry's Mod addons folder.
REM Because the full game is not required only the necessary resource files will be copied.


(@ECHO "mountcfg" & @ECHO { & @ECHO "cstrike"  "%clientDir%\addons\cstrike" & @ECHO }) > "%clientDir%\cfg\mount.cfg"
(@ECHO "gamedepotsystem" & @ECHO { & @ECHO "cstrike"  "1" & @ECHO }) > "%clientDir%\cfg\mountdepots.txt"

REM The script updates Garry's Mod configuration files to ensure the downloaded content is loaded.


DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\steamcmd & RMDIR /s /q %temp%\cstrike

REM MS Docs: The temp folder is not managed by Windows and it is the responsibility of the developer using it to clean up after themselves.
REM This may no longer be true in Windows 10.
