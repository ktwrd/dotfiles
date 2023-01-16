#!/bin/bash

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
_install_dnf() {
    sudo dnf install -y \
        python3 \
        python3-pip \
        wget \
        curl \
        git \
        zsh \
        nano \
        flatpak
	if [ -f "ocs-url-3.1.0-1.x86_64.rpm" ]; then
		rm ocs-url-3.1.0-1.x86_64.rpm
	fi
	wget https://res.kate.pet/upload/e241d69e-d407-45f2-a160-25f28e8c7462/ocs-url-3.1.0-1.x86_64.rpm
	sudo dnf install ./ocs-url-3.1.0-1.x86_64.rpm -y
	rm ocs-url-3.1.0-1.x86_64.rpm
}
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
		imwheel
	sudo apt install -y \
		libqt5svg5 \
		qml-module-qtquick-controls
	if [ -f "ocs-url_3.1.0-0ubuntu1_amd64.deb" ]; then
		rm ocs-url_3.1.0-0ubuntu1_amd64.deb
	fi
	wget https://res.kate.pet/upload/bbbb2a37-8265-4d5e-98c2-74dd85638186/ocs-url_3.1.0-0ubuntu1_amd64.deb
	sudo apt install ./ocs-url_3.1.0-0ubuntu1_amd64.deb -y
	rm ocs-url_3.1.0-0ubuntu1_amd64.deb
}
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
		com.visualstudio.code \
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
}

DISTRO=$(_getdistro)
DISTROVERSION=$(_getdistroversion)
PACKAGEMAN=$(_getpkman)
TIMESTAMP=$(date +%s)

echo Installing packages
if [[ $PACKAGEMAN = "apt" ]]
then
    _install_apt
elif [[ $PACKAGEMAN = "dnf" ]]
then
    _install_dnf
else
    echo "Unsupported Distro"
fi

if command -v flatpak &> /dev/null
then
    _install_flatpak
fi

echo Copying Home Folder
find ./linux/user_home_folder/ -type d -maxdepth 1 -regex '^\..*' -exec cp -rvf {} ~/ \;
echo "Run \"source ~/.zshrc\" to load"
