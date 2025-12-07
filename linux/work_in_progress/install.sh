#!/usr/bin/env bash

_postinstall() {
    git config --global credential.credentialStore secretservice
    
    dotnet tool install -g git-credential-manager
    echo "IMPORTANT: Configure CSM with 'git-credential-manager configure'"
}

echo "[install] calling install-flatpak.sh"
./install-flatpak.sh

if [ -f "/etc/redhat-release" ]; then
    echo "[install] calling install-dnf.sh"
    ./install-dnf.sh
fi
if grep -wq "debian" /etc/os-release; then
    echo "[install] calling install-apt.sh"
    ./install-apt.sh
fi

_postinstall
