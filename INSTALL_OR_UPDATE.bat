@echo off

if exist ".git\shallow.lock" (
	erase /f /q ".git\shallow.lock"
)

REM Get the name of the current folder
for %%F in ("%~dp0.") do set "currentFolder=%%~nF"

REM Check if the folder name matches the allowed names
if /i not "%currentFolder%"=="InfiniteFusion" (
    echo ERROR: This script must be run from a folder named "InfiniteFusion".
    echo YOUR folder name: "%currentFolder%"
    echo Please rename the folder to "InfiniteFusion" EXACTLY and try again.
    pause
    exit /b 1
)

set mgit=".\REQUIRED_BY_INSTALLER_UPDATER\cmd\git.exe"

REM Branch to install/update from. Priority: 1st argument, then update_branch.txt, then nuzlocke-mode.
set "branch=nuzlocke-mode"
if exist "update_branch.txt" set /p branch=<"update_branch.txt"
if not "%~1"=="" set "branch=%~1"
echo Updating from branch: %branch%
%mgit% init .
%mgit% remote add origin "https://github.com/MrChuck123/infinitefusion-e18.git" >nul 2>&1
%mgit% fetch --depth=1 origin "%branch%"
if %errorlevel% neq 0 (
    echo:
    echo Failed to download update. Reverting to previous game version.
    pause
)
%mgit% reset --hard "origin/%branch%"

echo:
echo Installation Complete.  
echo If you do not see additional files in your folder, screenshot this window to #tech-support for further help.
pause
