@echo off

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



set "folderPicker="(new-object -COM 'Shell.Application').BrowseForFolder(0,'Please select your sharedcontent directory.',0,0).self.path""
for /f "usebackq delims=" %%I in (`powershell -command %folderPicker%`) do set "sharedcontent=%%I"
rem Prompt the user to select their sharedcontent directory rather than assume where it's located.



set /p account="PLEASE ENTER YOUR STEAM USERNAME: "
:MENU
cls
echo Username: %account% 
echo 0 - Enter a new username.
echo.
echo Install/Update:
echo.
echo 1 - HL2 + EP1 + EP2
echo 2 - CS:S
echo 3 - TF2
echo 4 - QUIT
echo.
set /p input="PLEASE ENTER 0, 1, 2, 3, OR 4: "

if %input%==0 cls && set /p account="PLEASE ENTER YOUR STEAM USERNAME: " && goto MENU

if %input%==1 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login %account% +force_install_dir %install_dir%\ep2 +app_update 420 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\hl2" "%sharedcontent%\hl2" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\episodic" "%sharedcontent%\episodic" "*.vpk" ^
&& start /b /wait robocopy /is /it /mov "%temp%\steamcmd\ep2\ep2" "%sharedcontent%\ep2" "*.vpk" ^
&& goto MENU

if %input%==2 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %install_dir%\cstrike +app_update 232330 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%install_dir%\cstrike\cstrike" "%sharedcontent%\cstrike" "*.vpk" ^
&& goto MENU

if %input%==3 ^
start /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %install_dir%\tf +app_update 232250 validate +quit ^
&& start /b /wait robocopy /is /it /mov "%install_dir%\tf\tf" "%sharedcontent%\tf" "*.vpk"
&& goto MENU

if %input%==4 
del /q %temp%\steamcmd.zip ^
& rmdir /s /q %temp%\steamcmd ^
& exit
