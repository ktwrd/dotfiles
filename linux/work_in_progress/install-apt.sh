#!/usr/bin/env bash

_addrepo_sourcegit() {
    if [ -f "/etc/apt/sources.list.d/sourcegit.sources" ]; then
        echo "[addrepo_sourcegit] sourcegit.sources alredy exists. skipping"
    else
        sudo curl https://codeberg.org/api/packages/yataro/debian/repository.key -o /etc/apt/keyrings/sourcegit.asc
        sudo cat >/etc/apt/sources.list.d/sourcegit.sources <<EOL
Types: deb
URIs: https://codeberg.org/api/packages/yataro/debian/
Suites: generic
Components: main
Signed-By: /etc/apt/keyrings/sourcegit.asc

EOL
        echo "[addrepo_sourcegit] done"
    fi
}
_addrepo_discord() {
    wget https://palfrey.github.io/discord-apt/discord-repo_1.2_all.deb
    sudo dpkg -i discord-repo_1.2_all.deb
    if [ -f "./discord-repo_1.2_all.deb" ]; then
        /usr/bin/rm ./discord-repo_1.2_all.deb
    fi
    echo "[addrepo_discord] done"
}

_addrepo_microsoft() {
    wget https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
}

echo "[apt] adding repos" \
    && _addrepo_sourcegit

sudo apt update

echo "[apt] installing packages"
sudo apt install -y \
    discord \
    sourcegit \
    git

# dev
sudo apt install -y \
    netstandard-targeting-pack-2.1 \
    dotnet-sdk-10.0 \
    dotnet-runtime-10.0 \
    aspnetcore-runtime-10.0 \
    aspnetcore-targeting-pack-10.0 \
    dotnet-sdk-8.0 \
    dotnet-runtime-8.0 \
    aspnetcore-runtime-8.0 \
    aspnetcore-targeting-pack-8.0 \
    libgdiplus

