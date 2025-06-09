wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install
/usr/bin/apt update
/usr/bin/apt install -y \
    dotnet-sdk-6.0 \
    dotnet-sdk-8.0 \
    dotnet-sdk-9.0 \
    dotnet-runtime-6.0 \
    dotnet-runtime-8.0 \
    dotnet-runtime-9.0 \
    aspnetcore-runtime-6.0 \
    aspnetcore-runtime-8.0 \
    aspnetcore-runtime-9.0 \
    aspnetcore-targeting-pack-6.0 \
    aspnetcore-targeting-pack-8.0 \
    aspnetcore-targeting-pack-9.0 \
