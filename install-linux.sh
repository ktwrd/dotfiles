#!/bin/bash

#----------------------------------------------------------------
# Log Functions
#----------------------------------------------------------------
_printheader() {
    logdate=$(date)
    # white background
    # black foreground
    printf "\u001b[47m\u001b[38;5;238m[$logdate] [DBG] $1\u001b[0m\n"
}
_printerror() {
    logdate=$(date)
    # red background
    # black foreground
    printf "\u001b[48;5;196m\u001b[30;1m[$logdate] [ERR] $1\u001b[0m\n" >&2
}
_log() {
    logdate=$(date)
    #black background
    #light blue foreground
    printf "\e[40m\e[36m[$logdate] [LOG] $1\u001b[0m\n"
}

#----------------------------------------------------------------
# Helper Functions
#----------------------------------------------------------------
_getdistro() {
    local DISTROID=$(grep '^ID=' /etc/os-release | sed 's/ID\=//g')
    if [ $(echo $DISTROID | wc -m) -lt 2 ]
    then
        _printerror "Unsupported Distro"
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
_install_home() {
    cp ./linux/user_home_folder/.zshrc ~/.zshrc
    cp ./linux/user_home_folder/.sharedrc ~/.sharedrc
    mkdir -p ~/.local/share/neofetch
    cp ./linux/user_home_folder/.local/share/neofetch/* ~/.local/share/neofetch/
    cd $SCRIPT_DIR
    _install_home_config;
    _printheader "Done: _install_home"
}
_install_home_config()
{
    git config --global credential.helper store
    _printheader "Done: _install_home_config"
}
#----------------------------------------------------------------
# Installer
# | Dnf
#   |- _install_dnf_powershell
#   |- _install_dnf_ocs
#   |- _install_dnf_dotnet
#   |- _install_dnf_vscode
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
    _install_dnf_powershell;
    _install_dnf_ocs;
    _install_dnf_dotnet;
    _install_dnf_vscode;
    _install_dnf_docker;
    _printheader "Done: _install_dnf"
}
_install_dnf_docker() {
    _printheader "Installing Docker"
    
    # remove existing install
	sudo dnf remove -y docker \
		docker-client \
		docker-client-latest \
		docker-common \
		docker-latest \
		docker-latest-logrotate \
		docker-logrotate \
		docker-selinux \
		docker-engine-selinux \
		docker-engine
		
	# add repo
	sudo dnf -y install dnf-plugins-core
	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo -y
	
	# install docker
	sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	
	# enable & start service
	sudo systemctl enable --now docker
    _printheader "Done: _install_dnf_docker"
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
_install_dnf_powershell()
{
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
    sudo dnf install powershell -y
    _printheader "Done: _install_dnf_powershell"
}
_install_dnf_dotnet()
{
    # import keys
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    # add repo
    FEDORA_VERSION=$(rpm -E %fedora)
    sudo wget -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/fedora/$FEDORA_VERSION/prod.repo

    # install dotnet
    sudo dnf install -y \
        dotnet-sdk-7.0 \
        dotnet-sdk-6.0 \
        aspnetcore-runtime-7.0 \
        aspnetcore-runtime-6.0 \
        dotnet-runtime-7.0 \
        dotnet-runtime-6.0
}
_install_dnf_vscode()
{
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf install code -y
    _printheader "Done: _install_dnf_vscode"
}
#----------------------------------------------------------------
# Installer
# | Apt
#   |- _install_apt_powershell
#   |- _install_apt_ocs
#   |- _install_apt_dotnet
#   |- _install_apt_vscode
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
        konsole \
        yakuake \
        vulkaninfo \
        whois \
        strawberry \
        build-essential \
        dkms \
        linux-headers-$(uname -r) \
        joystick \
        libboost \
        libboost-all-dev \
        clang \
        hugo \
        openvpn \
        micro \
        freerdp2-x11 \
        syncthing \
        remmina
    _install_apt_powershell;
    _install_apt_ocs;
    _install_apt_dotnet;
    _install_apt_vscode;
    _install_apt_docker;
    curl -1sLf https://dl.anyware.hp.com/DeAdBCiUYInHcSTy/pcoip-client/cfg/setup/bash.deb.sh | sudo -E bash
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
        dotnet-sdk-8.0 \
        dotnet-sdk-6.0 \
        dotnet-runtime-8.0 \
        dotnet-runtime-6.0 \
        aspnetcore-targeting-pack-8.0 \
        aspnetcore-targeting-pack-6.0 \
        aspnetcore-runtime-8.0 \
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
    rm microsoft.gpg
    _printheader "Done: _install_apt_vscode"
}
_install_apt_docker()
{
    _printheader "Installing Docker"
    
    # remove existing install
    sudo apt-get remove docker docker-engine docker.io containerd runc -y

    # Installing core depends
    sudo apt-get update -y
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    # Add repo key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add repo
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


    sudo apt update
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    _printheader "Done: _install_apt_docker"
}
#----------------------------------------------------------------
# Installer
# |- Flatpak
#   |- social
#   |- media
#   |- crypto
#   |- util
#   |- sdk
#   |- other
#----------------------------------------------------------------
_install_flatpak() {
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    _log "Installing flatpak->social"
    #social
    flatpak install -y \
        com.discordapp.Discord \
        im.srain.Srain \
        in.cinny.Cinny \
        im.riot.Riot
        
    _log "Installing flatpak->network"
    #network
    flatpak install -y flathub \
        org.x.Warpinator \
        com.github.micahflee.torbrowser-launcher \
        app.drey.Warp \

    _log "Installing flatpak->crypto"
    #crypto
    flatpak install -y flathub \
        com.authy.Authy \
        org.gnome.Keysign \
        com.yubico.yubioath \
        com.github.arshubham.cipher

    _log "Installing flatpak->media"
    #media
    flatpak install -y flathub \
        tv.plex.PlexDesktop \
        org.videolan.VLC \
        org.kde.kdenlive \
        com.github.iwalton3.jellyfin-media-player \
        com.github.childishgiant.mixer \
        org.thentrythis.Samplebrain

    _log "Installing flatpak->util"
    #util
    flapak install -y flathub \
        com.github.tchx84.Flatseal \
        org.gnome.baobab \
        org.jdownloader.JDownloader \
        com.github.artemanufrij.regextester \
        com.github.debauchee.barrier \

    _log "Installing flatpak->sdk"
    #sdk
    flatpak install -y flathub \
        "org.freedesktop.Sdk.Extension.texlive//21.08" \
        "org.freedesktop.Sdk.Extension.node18//22.08" \
        "org.freedesktop.Sdk.Extension.llvm15//22.08" \
        "org.freedesktop.Sdk.Extension.rust-stable//22.08" \
        "org.freedesktop.Sdk.Extension.dotnet5//21.08" \
        "org.freedesktop.Sdk.Extension.dotnet6//22.08" \
        "org.freedesktop.Sdk.Extension.dotnet7//22.08" \
        "org.freedesktop.Sdk.Extension.dotnet//20.08" \
        "org.freedesktop.Sdk.Extension.mono6//20.08"

    _log "Installing flatpak->other"
    #other
    flatpak install -y \
        com.github.phase1geo.minder \
        com.dec05eba.gpu_screen_recorder \
        com.github.LongSoft.UEFITool \
        com.vysp3r.ProtonPlus \
        com.whitemagicsoftware.kmcaster \
        io.github.arunsivaramanneo.GPUViewer \
        io.qt.Designer \
        md.obsidian.Obsidian

    _printheader "Done: _install_flatpak"
}
_install_ohmyzsh()
{
    _log "Installing oh-my-zsh"
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O oh-my-zsh.sh
    chmod +x oh-my-zsh.sh
    ./oh-my-zsh.sh --unattended
    rm oh-my-zsh.sh
    _printheader "Done: _install_ohmyzsh"
}

DISTRO=$(_getdistro)
DISTROVERSION=$(_getdistroversion)
PACKAGEMAN=$(_getpkman)
TIMESTAMP=$(date +%s)


_log "Detected package manager as \"$PACKAGEMAN\""

#----------------------------------------------------------------
# Main
# | Steps
#----------------------------------------------------------------
step_pkg() {
    _printheader "Running step_pkg"
    
    if [[ $PACKAGEMAN = "apt" ]]
    then
        _install_apt
    elif [[ $PACKAGEMAN = "dnf" ]]
    then
        _install_dnf
    else
        _printerror "Unsupported Distro"
    fi
    
    if command -v zsh &> /dev/null
    then
        if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]
        then
            _printheader "Installing oh-my-zsh"
            _install_ohmyzsh;
        else
        
            _printerror "oh-my-zsh is already installed"
        fi
    else
        _printerror "zsh not found!!!!"s
    fi
    _printheader "Done: step_pkg"
}
step_flatpak() {
    _printheader "Running step_flatpak"
    if command -v flatpak &> /dev/null
    then
        _install_flatpak
    else
        _printerror "Flatpak not found!!"
        _printheader "Done: _install_flatpak"
        exit 1
    fi
    _printheader "Done: step_flatpak"
}
step_home() {
    _printheader "Running step_home"
    _install_home
    _log "Run \"source ~/.zshrc\" to load"
    _printheader "Done: step_home"
}
step_all() {
    _printheader "Running step_all"
    step_pkg
    step_flatpak
    step_home
    _printheader "Done: step_all"
}
step_usage() {
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
    # |-| _install_home
    #   |-| _install_home_config

    step_all
elif [[ $1 == "help" ]]
then
    step_usage
else
    _printerror "Unrecognized argument \"$1\""
    step_usage
fi


