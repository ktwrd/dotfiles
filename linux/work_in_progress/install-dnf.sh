#!/usr/bin/env bash
set -xeu -o pipefail
_addrepo_vscode() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
}
_addrepo_googlecloudsdk() {
    sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
    sudo dnf install -y libxcrypt-compat.x86_64
}

_installdocker_remove_existing() {
    sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
}

# add repos
echo "[dnf] adding repos"
    # sourcegit
    sudo dnf config-manager --add-repo https://codeberg.org/api/packages/yataro/rpm.repo
    # rpmfusion
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # vscode
    _addrepo_vscode
    _addrepo_googlecloudsdk

# rpmfusion - enable features
echo "[dnf] enabling rpmfusion features/repos"
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
    sudo dnf install -y rpmfusion-\*-appstream-data

# rpmfusion - full ffmpeg
echo "[dnf] switching to full ffmpeg"
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing

# docker
echo "[dnf] installing docker"
while true; do
    read -p "Remove existing docker installation? " yn
    case $yn in
        [Yy]* ) _installdocker_remove_existing; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
    sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# .NET
echo "[dnf] installing dotnet"
    sudo dnf install -y \
        glibc libgcc ca-certificates openssl-libs libstdc++ libicu tzdata krb5-libs zlib \
        aspnetcore-targeting-pack-10.0 \
        aspnetcore-targeting-pack-9.0 \
        aspnetcore-targeting-pack-8.0 \
        aspnetcore-runtime-10.0 \
        aspnetcore-runtime-9.0 \
        aspnetcore-runtime-8.0 \
        aspnetcore-runtime-dbg-10.0 \
        aspnetcore-runtime-dbg-9.0 \
        aspnetcore-runtime-dbg-8.0 \
        dotnet-runtime-10.0 \
        dotnet-runtime-9.0 \
        dotnet-runtime-8.0 \
        dotnet-runtime-dbg-10.0 \
        dotnet-runtime-dbg-9.0 \
        dotnet-runtime-dbg-8.0 \
        dotnet-sdk-10.0 \
        dotnet-sdk-9.0 \
        dotnet-sdk-8.0 \
        dotnet-sdk-aot-10.0 \
        dotnet-sdk-aot-9.0 \
        dotnet-sdk-dbg-10.0 \
        dotnet-sdk-dbg-9.0 \
        dotnet-sdk-dbg-8.0

# everything else
echo "[dnf] installing everything else"
sudo dnf install -y \
    aria2 \
    ark \
    asciinema \
    cabextract \
    code \
    conky \
    curl \
    diffstat \
    dolphin \
    dos2unix \
    doxygen \
    ffmpeg \
    fish \
    flatpak \
    flatpak-kcm \
    fwupd \
    git \
    git-lfs \
    google-cloud-cli \
    gparted \
    grubby \
    gwenview \
    hyfetch \
    jetbrains-mon-fonts-all \
    kate \
    kleopatra \
    kwrite \
    libunity \
    micro \
    ncurses \
    nmap \
    nmap-ncat \
    nodejs \
    ntfs-eg \
    ntfsprogs \
    openssh-clients \
    orca \
    parted \
    protonmail-bridge \
    rclone \
    rsync \
    sourcegit \
    spectacle \
    strawberry \
    syncthing \
    tar \
    traceroute \
    ulauncher \
    unzip \
    wireshark \
    zip
