#!/usr/bin/env bash

_addrepo_sourcegit() {
    sudo dnf config-manager --add-repo https://codeberg.org/api/packages/yataro/rpm.repo
}


echo "[apt] adding repos" \
    && _addrepo_sourcegit


# dev
sudo dnf install -y \
    glibc libgcc ca-certificates openssl-libs libstdc++ libicu tzdata krb5-libs zlib \
    dotnet-sdk-10.0 \
    dotnet-sdk-aot-10.0 \
    aspnetcore-runtime-10.0 \
    dotnet-runtime-10.0
