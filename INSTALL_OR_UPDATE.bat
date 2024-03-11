@echo off

.\REQUIRED_BY_INSTALLER_UPDATER\7z.exe e -spf -aoa "REQUIRED_BY_INSTALLER_UPDATER\MinGit.7z"

set mgit=".\REQUIRED_BY_INSTALLER_UPDATER\cmd\git.exe"
%mgit% init .
%mgit% remote add origin "https://github.com/infinitefusion/infinitefusion-e18.git"
%mgit% fetch origin releases
%mgit% reset --hard origin/releases

echo:
echo Installer/Updater made by Hungry Pickle
echo:
echo Thank you for installing or updating! You can close this window now.
pause