#Requires -RunAsAdministrator
#Import-Module -DisableNameChecking $PSScriptRoot\shared.ps1
#Import-Module -Global -DisableNameChecking $PSScriptRoot\debloat.ps1
. $PSScriptRoot\debloat.ps1
$Choco_Packages = @(
    "7zip",
    "apache-netbeans.portable",
    "audacity",
    "audacity-ffmpeg",
    "audacity-lame",
    "blender",
    "ccleaner",
    "discord",
    "discordchatexporter",
    "dotnet",
    "dotnetcore",
    "dotnetfx",
    "everything",
    "figma",
    "firefox",
    "geany",
    "git",
    "github-desktop",
    "imageglass",
    "javaruntime",
    "jdk11",
    "jdk8",
    "libreoffice-fresh",
    "microsoft-teams",
    "microsoft-visual-cpp-build-tools",
    "microsoft-windows-terminal",
    "nodejs-lts",
    "notepad2",
    "notepadplusplus",
    "putty",
    "python3",
    "python2",
    "steam-client",
    "telegram",
    "visualstudio2019community",
    "vlc",
    "vscode",
    "wget",
    "windows-sdk-10",
    "xna",
    "wsl",
    "wsl2"
    "wsl-debiangnulinux",
    "wsl-ssh-pageant",
    "wsl-ssh-pageant-gui",
    "lxrunoffline"
)

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host "                                               3"
    Start-Sleep 1
    Write-Host "                                               2"
    Start-Sleep 1
    Write-Host "                                               1"
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$DebloatFolder = "C:\Temp\Windows10Debloater"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -OutputDirectory "$DebloatFolder"

# Debloat Windows

## Uninstall OneDrive
#
Debloat_OneDriveRemove
Debloat_CortanaDisable
Debloat_RemoveBloatwareRegkeys
Debloat_EdgePDFStop
Debloat_UnpinStart
Debloat_LastUsedDisable
Debloat_ProtectPrivacy
Debloat_FixWhitelistedApps

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
iwr -useb https://community.chocolatey.org/install.ps1 | iex


$Choco_Packages_Joined = $Choco_Packages -join " "

refreshenv
choco feature disable -n=allowGlobalConfirmation
ForEach ($key in $Choco_Packages) {
    choco install $key -y
}
choco feature enable -n=allowGlobalConfirmation
#choco install $Choco_Packages_Joined -y
refreshenv