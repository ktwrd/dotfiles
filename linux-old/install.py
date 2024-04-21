

import os, subprocess, shutil

runinfo = {
    packagemanager: "",
    user: "",
    ts_start: 0
}

# =================
# Utilities
termInfo = {
    rows: 0,
    columns: 0
}
def getTerminalDimensions():
    rows, columns = os.popen('stty size', 'r').read().split()
    termInfo["rows"] = rows
    termInfo["columns"] = columns
getTerminalDimensions()
def displayHeader(content=""):
    content = "= "+content+" "
    
    lineWidth = round((termInfo["columns"] - len(content))/2)
    
    if ((lineWidth * 2) + len(content)) == termInfo["columns"]:
        content = content[1:]
    if ((lineWidth * 2) + len(content)) < termInfo["columns"]:
        content = content + "="
        
    print((char * lineWidth) + content + (char * lineWidth))
    
def file_write(lines, location):
    with open(location, "w") as file:
        file.write("\n".join(lines))
        file.close()

# =================
# Parse Arguments
runinfo["packagemanager"] = str(sys.argv[1])
runinfo["user"] = str(sys.argv[2])
runinfo["ts_start"] = int(sys.argv[3])
runinfo["distro"] = str(sys.argv[4])
runinfo["distro_ver"] = str(sys.argv[5])

# ================
# Package Manager Utilities
packagemanager_lookup = {
    "apt": {
        "remove": "/usr/bin/apt-get remove -y {0}",
        "install": "/usr/bin/apt-get install -y {0}"
    },
    "zypper": {
        "remove": "/usr/bin/zypper rm -y {0}",
        "install": "/usr/bin/zypper in -y {0}"
    },
    "yum": {
        "remove": "/usr/bin/yum remove -y {0}",
        "install": "/usr/bin/yum install -y {0}",
        "addrepo": "/usr/bin/dnf config-manager --add-repo {0}",
        "installgroup": "/usr/bin/yum groups install -y {0}"
    }
}
def package_install(packageArray, sectionName):
    displayHeader("[{0}] Installing Packages".format(sectionName))
    subprocess.run(
        packagemanager_lookup[runinfo["packagemanager"]]["install"]
        .format(" ".join(packageArray))
    )  
def package_remove(packageArray, sectionName):
    displayHeader("[{0}] Removing Packages".format(sectionName))
    subprocess.run(
        packagemanager_lookup[runinfo["packagemanager"]]["remove"]
        .format(" ".join(packageArray))
    )
def package_addrepo(repoArray, sectionName):
    displayHeader("[{0}] Adding Repos".format(sectionName))
    subprocess.run(
        packagemanager_lookup[runinfo["packagemanager"]]["addrepo"]
        .format(" ".join(repoArray))
    )
def package_installgroup(groupArray, sectionName):
    displayHeader("[{0}] Installing Groups".format(sectionName))
    subprocess.run(
        packagemanager_lookup[runinfo["packagemanager"]]["installgroup"]
        .format(" ".join(groupArray))
    )
    

def _install_pre():
    if runinfo["packagemanager"] == "yum":
        package_install([
            "dnf-plugins-core"
        ],"yum] [pre-install")
        pkgs = ["--nogpgcheck"]
        pkgs_rhel = pkgs+[
            "https://dl.fedoraproject.org/pub/epel/epel-release-latest-{0}.noarch.rpm".format(runinfo["distro_ver"]),
            "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-{0}.noarch.rpm".format(runinfo["distro_ver"]),
            "https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-{0}.noarch.rpm".format(runinfo["distro_ver"])
        ]
        pkgs_fedora = [
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-{0}.noarch.rpm".format(runinfo["distro_ver"]),
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-{0}.noarch.rpm".format(runinfo["distro_ver"])
        ]
        if runinfo["distro"] == "rhel":
            subprocess.run(["subscription-manager", "repos", "--enable", '"codeready-builder-for-rhel-{0}-{1}-rpms"'.format(runinfo["distro_ver"],subprocess.run(["uname", "-m"],stdout=subprocess.PIPE).stdout])
            package_install(pkgs_rhel,"yum] [pre-install")
        if runinfo["distro"] == "centos":
            subprocess.run(["/usr/bin/dnf", "config-manager", "--enable", "-y", "powertools"])
            subprocess.run(["/usr/bin/dnf", "config-manager", "--enable", "-y", "PowerTools"])
            package_install(pkgs_rhel,"yum] [pre-install")
        if runinfo["distro"] == "fedora":
            package_install(pkgs_fedora,"yum] [pre-install")
        subprocess.run(["/usr/bin/dnf", "groupupdate", "-y", "core")
        subprocess.run(["/usr/bin/dnf", "groupupdate", "multimedia", "-y", "--setop='install_weak_deps=False'", "--exclude=PackageKit-gstreamer-plugin"])
        subprocess.run(["/usr/bin/dnf", "groupupdate", "sound-and-video", "-y"])
        
        package_install([
            "rpmfusion-free-release-tainted",
            "rpmfusion-nonfree-release-tainted"
        ],"tainted rpmfusion")
def _install_repos():
    if runinfo["packagemanager"] == "yum":
        package_addrepo([
            "https://cli.github.com/packages/rpm/gh-cli.repo",
            "https://download.docker.com/linux/fedora/docker-ce.repo"
        ],"misc")    
def _install_groups():
    if runinfo["packagemanager"] == "yum":
        package_installgroup([
            '"Office/Productivity"',
            "Editors",
            '"C Development Tools and Libraries"',
            '"Development Tools"'
        ],"misc")
def _install_docker():
    package_remove([
        "docker",
        "docker-client",
        "docker-client-latest",
        "docker-common",
        "docker-latest",
        "docker-latest-logrotate",
        "docker-logrotate",
        "docker-selinux",
        "docker-engine-selinux",
        "docker-engine"
    ], "docker")
    package_install([
        "docker-ce",
        "docker-ce-cli",
        "containerd.io"
    ], "docker")
    subprocess.run(["systemctl", "enable", "--now", "docker"])
def _install_snap():
    package_install([
        "snapd"
    ], "snap")
    subprocess.run(["snap", "install", "snap", "core"])
    subprocess.run(["ln", "-s", "/var/lib/snapd/snap", "/snap"])
    subprocess.run(["systemctl", "enable", "--now", "snapd"])
def _install_packages():
    package_install([
        "curl",
        "install",
        "cmake",
        "gcc",
        "g++",
        "clang",
        "make"
    ], "make tools")
    
    package_install([
        "nodejs",
        "npm"
    ], "nodejs")
    package_install([
        "qt5-qtbase", 
        "qt5-qtbase-gui", 
        "qt5-qtsvg", 
        "qt5-qtdeclarative", 
        "qt5-qtquickcontrols"
    ], "ocs-url")
    if runinfo["packagemanager"] == "yum":
        package_install(["https://REDACTED/upload/ocs-url-3.1.0-1.rpm"], "ocs-url")
    if runinfo["packagemanager"] == "apt":
        subprocess.run(["/usr/bin/wget", "https://REDACTED/upload/ocs-url-3.1.0-1.deb"])
        package_install([
            "libqt5svg5",
            "qml-module-qtquick-controls"
        ],"ocs-url-dependencies")
        package_install(["./ocs-url-3.1.0-1.deb"],"ocs-url")
    if runinfo["packagemanager"] == "zypper":
        package_install([
            "libQt5Svg5",
            "libqt5-qtquickcontrols"
        ], "ocs-url-dependencies")
        subprocess.run(["/usr/bin/wget", "https://REDACTED/upload/ocs-url-3.1.0-1.rpm"])
        subprocess.run(["/usr/bin/rpm", "-i", "ocs-url-3.1.0-1.rpm"])
    subprocess.run(["rm", "-rf", "ocs-url-3*"])
    
    subprocess.run(["curl", "--proto", "'=https'", "--tlsv1.2", "-sSf", "https://sh.rustup.rs", "|", "sh"])
    
    package_install.run([
        "thunderbird",
        "firefox",
        "geany",
        "java-latest-openjdk",
        "lollypop",
        "gnome-boxes",
        "konsole",
        "openvpn",
        "git-cola",
        "gh",
        "micro",
        "go",
        "ruby",
        "rubygem-tk",
        "rubygem-tk-doc",
        "rubygem-rake",
        "rubygem-test-unit",
        "okular",
        "blender",
        "ufw",
        "htop",
        "flatpak",
        "zsh",
        "cargo",
        "gnome-font-viewer",
        "lightdm-gtk-greeter-settings"
    ], "everything")
    
    subprocess.run(["go", "install", "github.com/nektos/act@latest"],"github act")
def _install_packages_snap():
    displayHeader("Snap Packages")
    subprocess.run(["systemctl","restart","snapd"])
    subprocess.run([
        "snap",
        "install",
        "matroska-tools",
        "snap-store",
        "node-red",
        "beekeeper-studio",
        "vlc",
        "teams",
        "bpytop"
    ])
    displayHeader("Snap Packages (Classic)")
    subprocess.run([
        "snap",
        "install",
        "--classic",
        "slack",
        "discord",
        "code"
    ])
def _install_packages_flatpak():
    displayHeader("Flatpak Packages")
    subprocess.run([
        "flatpak",
        "remote-add",
        "--if-not-exists",
        "flathub",
        "https://flathub.org/repo/flathub.flatpakrepo"
    ])
    subprocess.run([
        "flatpak",
        "install",
        "-y",
        "flathub",
        "com.spotify.Client"
    ])
def _install_spotifyPatch():
    displayHeader("Patching Spotify")
    subprocess.run([
        "rm","-rf","spotify-adblock"
    ])
    subprocess.run("git clone https://github.com/abba23/spotify-adblock.git")
    subprocess.run("cd spotify-adblock && make")
    subprocess.run("make")
    
    subprocess.run("rm -rf ~/.spotify-adblock ~/.config/spotify-adblock")
    
    subprocess.run("mkdir -p ~/.spotify-adblock")
    subprocess.run("cp ~/spotify-adblock/target/release/libspotifyadblock.so ~/.spotify-adblock/spotify-adblock.so")
    
    subprocess.run("mkdir -p ~/.config/spotify-adblock")
    subprocess.run("cp ~/spotify-adblock/config.toml ~/.config/spotify-adblock")
    
    subprocess.run([
        "flatpak",
        "override",
        "--user",
        "--filesystem='~/.spotify-adblock/spotify-adblock.so",
        "--filesystem='~/.config/spotify-adblock/config.toml'",
        "com.spotify.Client"
    ])
    subprocess.run("mkdir -p ~/.local/share/applications/")
    
    subprocess.run("rm -rf ~/.local/share/applications/Spotify.desktop")
    file_write([
        "[Desktop Entry]",
        "Type=Application",
        "Name=Spotify (adblock)",
        "GenericName=Music Player",
        "Icon=com.spotify.Client",
        "Exec=flatpak run --file-forwarding --command=sh com.spotify.Client -c 'eval \"$(sed s#LD_PRELOAD=#LD_PRELOAD=$HOME/.spotify-adblock/spotify-adblock.so:#g /app/bin/spotify)\"' @@u %U @@",
        "Terminal=false",
        "MimeType=x-scheme-handler/spotify;",
        "Categories=Audio;Music;Player;AudioVideo;",
        "StartupWMClass=spotify"
    ],"~/.local/share/applications/Spotify.desktop")
def _install_ohmyzsh():
    displayHeader("Installing oh-my-zsh!")
    subprocess.run([
        "sh",
        "-c",
        '"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"',
        '""',
        "--unattended"
    ])
def _install_theme():
    subprocess.run("git clone https://github.com/ktwrd/dotfiles")
    subprocess.run("cp --force -Rv dotfiles/linux/* /")
    subprocess.run("xfce4-panel-profiles load dotfiles/xfce4/panelprofile.tar.bz2")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace0/last-image --set /usr/share/backgrounds/desktop-custom/png")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace0/image-style --set 2")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace1/last-image --set /usr/share/backgrounds/desktop-custom/png")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace1/image-style --set 2")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace2/last-image --set /usr/share/backgrounds/desktop-custom/png")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace2/image-style --set 2")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace3/last-image --set /usr/share/backgrounds/desktop-custom/png")
    subprocess.run("xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual-1/workspace3/image-style --set 2")
    
    subprocess.run("xfconf-query --channel xsettings --property /Net/ThemeName --set PLATINUM")
    subprocess.run("xfconf-query --channel xsettings --property /Net/IconThemeName --set Haiku")


steps = {
    "Prerequisites": _install_pre,
    "Repositories": _install_repos,
    "Groups": _install_groups,
    "Docker": _install_docker,
    "Snap": _install_snap,
    "Packages": _install_packages,
    "Packages (Snap)": _install_packages_snap,
    "Packages (Flatpak)": _install_packages_flatpak,
    "Patching Spotify": _install_spotifyPatch,
    "Customization": _install_theme,
    "oh-my-zsh!": _install_ohmyzsh
}

for key,value in enumerate(steps):
    displayHeader(key)
    value()

displayHeader("")
displayHeader("Installation Complete!")
displayHeader("")
