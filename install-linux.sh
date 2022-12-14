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
        micro
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
        micro
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

echo Copying Home Folder
find ./linux/home/kate/ -maxdepth 1 -regex '^\./.*' -exec /usr/bin/cp -rf {} ~/ \;
echo "Run \"source ~/.zshrc\" to load"