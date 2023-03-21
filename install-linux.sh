#!/bin/bash

#----------------------------------------------------------------
# Helper Functions
#----------------------------------------------------------------
_printheader() {
    printf "\u001b[47m\u001b[38;5;238m======== $1\u001b[0m\n"
}
_printerror() {
    printf "\u001b[48;5;196m\u001b[30;1mERR: $1\u001b[0m\n"
}

_getdistro() {
    local DISTROID=$(grep '^ID=' /etc/os-release | sed 's/ID\=//g')
    if [ $(echo $DISTROID | wc -m) -lt 2 ]
    then
        echo "Unsupported Distro"
        exit 1
    fi
    echo $DISTROID
}
_getdistroversion() {
    res=$(grep '^VERSION_ID=' /etc/os-release | sed 's/VERSION_ID\=//g')
    echo $res
}
_getpkman() {
    if [ -f "/etc/debian_version" ]; then
        echo "apt"
    elif [ -f "/etc/SuSE-release" ]; then
        echo "zypp"
    elif [ -f "/etc/redhat-release" ]; then
        echo "dnf"
    fi
}
_install_homedir() {
    find ./linux/user_home_folder/ -type d -maxdepth 1 -regex '^\..*' -exec cp -rvf {} ~/ \;
    cd ./linux/user_home_folder
    find . -d 1 -type f -exec install -vDm 755 "{}" "$HOME" \;
    cd $SCRIPT_DIR
    _printheader "Done: _install_homedir"
}
#----------------------------------------------------------------
# Installer
# | DNF
#----------------------------------------------------------------
_install_dnf() {
    sudo dnf install -y \
        python3 \
        python3-pip \
        wget \
        curl \
        git \
        zsh \
        nano \
        flatpak \
        neofetch \
        konsole
    _install_dnf_ocs;
    _printheader "Done: _install_dnf"
}
_install_dnf_ocs() {
    if [ -f "ocs-url-3.1.0-1.x86_64.rpm" ]; then
        rm ocs-url-3.1.0-1.x86_64.rpm
    fi
    wget https://res.kate.pet/upload/e241d69e-d407-45f2-a160-25f28e8c7462/ocs-url-3.1.0-1.x86_64.rpm
    sudo dnf install ./ocs-url-3.1.0-1.x86_64.rpm -y
    rm ocs-url-3.1.0-1.x86_64.rpm
    _printheader "Done: _install_dnf_ocs"
}
#----------------------------------------------------------------
# Installer
# | Apt
#----------------------------------------------------------------
_install_apt() {
    sudo apt update
    sudo apt install -y \
        python3 \
        python3-pip \
        wget \
        curl \
        git \
        zsh \
        nano \
        flatpak \
        imwheel \
        neofetch \
        konsole
    _install_apt_powershell;
    _install_apt_ocs;
    _install_apt_dotnet;
    _install_apt_vscode;
    _printheader "Done: _install_apt"
}
_install_apt_ocs()
{
    echo Installing OCS URL
    sudo apt install -y \
        libqt5svg5 \
        qml-module-qtquick-controls
    if [ -f "ocs-url_3.1.0-0ubuntu1_amd64.deb" ]; then
        rm ocs-url_3.1.0-0ubuntu1_amd64.deb
    fi
    wget https://res.kate.pet/upload/bbbb2a37-8265-4d5e-98c2-74dd85638186/ocs-url_3.1.0-0ubuntu1_amd64.deb
    sudo apt install ./ocs-url_3.1.0-0ubuntu1_amd64.deb -y
    rm ocs-url_3.1.0-0ubuntu1_amd64.deb
    _printheader "Done: _install_apt_ocs"
}
_install_apt_powershell()
{
    echo Installing PowerShell
    # Install system components
    sudo apt update  && sudo apt install -y curl gnupg apt-transport-https

    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Product feed
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'

    # Install PowerShell
    sudo apt update
    sudo apt install -y powershell
    _printheader "Done: _install_apt_powershell"
}
_install_apt_dotnet()
{
    echo Installing .NET
    wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb;
    sudo dpkg -i packages-microsoft-prod.deb;
    rm packages-microsoft-prod.deb;
    
    sudo apt update
    
    sudo apt install -y \
        dotnet-sdk-7.0 \
        dotnet-sdk-6.0 \
        dotnet-runtime-7.0 \
        dotnet-runtime-6.0 \
        aspnetcore-targeting-pack-7.0 \
        aspnetcore-targeting-pack-6.0 \
        aspnetcore-runtime-7.0 \
        aspnetcore-runtime-6.0 \
        libgdiplus
    _printheader "Done: _install_apt_dotnet"
}
_install_apt_vscode()
{
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt install -y apt-transport-https
    sudo apt update
    sudo apt install -y code
    _printheader "Done: _install_apt_vscode"
}
#----------------------------------------------------------------
# Installer
# | Flatpak
#----------------------------------------------------------------
_install_flatpak() {
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y \
        com.github.phase1geo.minder \
        com.github.artemanufrij.regextester \
        com.github.childishgiant.mixer \
        com.github.debauchee.barrier \
        com.github.iwalton3.jellyfin-media-player \
        com.github.micahflee.torbrowser-launcher \
        com.github.arshubham.cipher  \
        app.drey.Warp \
        chat.revolt.RevoltDesktop \
        com.dec05eba.gpu_screen_recorder \
        com.discordapp.Discord \
        com.github.LongSoft.UEFITool \
        com.vysp3r.ProtonPlus \
        com.whitemagicsoftware.kmcaster \
        com.yubico.yubioath \
        de.shorsh.discord-screenaudio \
        in.cinny.Cinny \
        io.github.arunsivaramanneo.GPUViewer \
        im.riot.Riot \
        im.srain.Srain \
        org.signal.Signal \
        org.gnome.Keysign \
        org.kde.kdenlive \
        io.qt.Designer \
        org.x.Warpinator \
        tv.plex.PlexDesktop \
        org.jdownloader.JDownloader \
        org.gnome.baobab \
        org.videolan.VLC \
        org.thentrythis.Samplebrain \
        com.authy.Authy \
        com.github.tchx84.Flatseal \
        md.obsidian.Obsidian
        
    flatpak install -y flathub \
        org.freedesktop.Sdk.Extension.texlive//21.08 \
        org.freedesktop.Sdk.Extension.node18//22.08 \
        org.freedesktop.Sdk.Extension.llvm15//22.08 \
        org.freedesktop.Sdk.Extension.rust-stable//22.08 \
        org.freedesktop.Sdk.Extension.dotnet5//21.08 \  
        org.freedesktop.Sdk.Extension.dotnet6//22.08 \  
        org.freedesktop.Sdk.Extension.dotnet7//22.08 \  
        org.freedesktop.Sdk.Extension.dotnet//20.08 \
        org.freedesktop.Sdk.Extension.mono6//20.08
    _printheader "Done: _install_flatpak"
}

DISTRO=$(_getdistro)
DISTROVERSION=$(_getdistroversion)
PACKAGEMAN=$(_getpkman)
TIMESTAMP=$(date +%s)


_printheader "Detected package manager as \"$PACKAGEMAN\""

#----------------------------------------------------------------
# Main
# | Steps
#----------------------------------------------------------------
function step_pkg() {
    _printheader "Running step_pkg"
    if [[ $PACKAGEMAN = "apt" ]]
    then
        _install_apt
    elif [[ $PACKAGEMAN = "dnf" ]]
    then
        _install_dnf
    else
        echo "Unsupported Distro"
    fi
    _printheader "Done: step_pkg"
}
function step_flatpak() {
    _printheader "Running step_flatpak"
    if command -v flatpak &> /dev/null
    then
        _install_flatpak
    else
        echo "Flatpak not found!!"
        _printheader "Done: _install_flatpak"
        exit 1
    fi
    _printheader "Done: step_flatpak"
}
function step_home() {
    _printheader "Running step_home"
    _install_homedir
    echo "Run \"source ~/.zshrc\" to load"
    _printheader "Done: step_home"
}
function step_all() {
    _printheader "Running step_all"
    step_pkg
    step_flatpak
    step_home
    _printheader "Done: step_all"
}
function step_usage() {
    _printheader "Usage"
    echo "Arguments:"
    echo "    pkg        Install system package manager packages"
    echo "    flatpak    Install flatpak packages"
    echo "    home       Install home script modifications (requires step_pkg)"
    echo "    all        Runs; pkg, flatpak, home"
    echo "    help       Displays this message"
    _printheader "Done: step_usage"
}

#----------------------------------------------------------------
# Main loop
#----------------------------------------------------------------
if [[ $1 == "pkg" ]]
then
    step_pkg
elif [[ $1 == "flatpak" ]]
then
    step_flatpak
elif [[ $1 == "home" ]]
then
    step_home
elif [[ $1 == "all" ]]
then

    # step_all
    # | step_pkg
    # |-| _install_apt
    #   |-| _install_apt_powershell
    #     | _install_apt_ocs
    #     | _install_apt_dotnet
    #   | _install_dnf
    #   |-| _install_dnf_ocs
    # | step_flatpak
    # | step_home

    step_all
elif [[ $1 == "help" ]]
then
    step_usage
else
    _printerror "Unrecognized argument \"$1\""
    step_usage
fi


