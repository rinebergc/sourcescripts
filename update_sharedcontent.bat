@ECHO OFF
SET account=***REMOVED***
SET copy_dir=C:\garrysmod\sharedcontent
SET install_dir=%temp%\staging

powershell -command "If (Test-Path -Path %temp%\steamcmd\steamcmd.exe -PathType leaf) {} Else {If (Test-Path -Path %temp%\steamcmd.zip -PathType leaf) {Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd} Else {(New-Object Net.WebClient).DownloadFile('https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip','%temp%\steamcmd.zip'); Expand-Archive -LiteralPath %temp%\steamcmd.zip -DestinationPath %temp%\steamcmd}}"

:MENU
CLS
ECHO Install/Update:
ECHO.
ECHO 1 - HL2 + EP1 + EP2
ECHO 2 - CS:S
ECHO 3 - TF2
ECHO 4 - QUIT
ECHO.
SET /p input="PLEASE ENTER 1, 2, 3, OR 4: "
IF %input%==1 START /b /wait %temp%\steamcmd\steamcmd.exe +login %account% +force_install_dir %install_dir%\ep2 +app_update 420 validate +quit && START /b /wait ROBOCOPY /is /it /mov "%install_dir%\ep2\hl2" "%copy_dir%\hl2" "*.vpk" && START /b /wait ROBOCOPY /is /it /mov "%install_dir%\ep2\episodic" "%copy_dir%\episodic" "*.vpk" && START /b /wait ROBOCOPY /is /it /mov "%install_dir%\ep2\ep2" "%copy_dir%\ep2" "*.vpk" && GOTO MENU
IF %input%==2 START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %install_dir%\cstrike +app_update 232330 validate +quit && START /b /wait ROBOCOPY /is /it /mov "%install_dir%\cstrike\cstrike" "%copy_dir%\cstrike" "*.vpk" && GOTO MENU
IF %input%==3 START /b /wait %temp%\steamcmd\steamcmd.exe +login anonymous +force_install_dir %install_dir%\tf +app_update 232250 validate +quit && START /b /wait ROBOCOPY /is /it /mov "%install_dir%\tf\tf" "%copy_dir%\tf" "*.vpk" && GOTO MENU
IF %input%==4 DEL /q %temp%\steamcmd.zip & RMDIR /s /q %temp%\steamcmd & RMDIR /s /q %temp%\staging & EXIT