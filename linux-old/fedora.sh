#!/usr/bin/sudo /bin/bash
clear
FEDORA_RELEASE=$(rpm -E %fedora)

printdt() {
	printf "\n\033[1;07m$1\033[0m\n"
}
printdt "[dnf] Updating Package Cache"
dnf update -y
dnf install -y dnf-plugins-core

printdt "[dnf] Upgrading packages"
dnf upgrade -y

# Enable EPEL
printdt "[dnf] Enabling EPEL"
dnf install epel-release -y

# Install RPM Fusion
printdt "[dnf] Installing RPM Fusion"
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$FEDORA_RELEASE.noarch.rpm 
dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$FEDORA_RELEASE.noarch.rpm
printdt "[RPMFusion] Installing Groups"
dnf groupupdate core -y
dnf groupupdate sound-and-video -y
printdt "[RPMFusion] Installing Tainted Repos"
dnf install rpmfusion-free-release-tainted -y
dnf install rpmfusion-nonfree-release-tainted -y
dnf update -y

printdt "[dnf] Installing Extra Repos"
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf update -y

# Install Groups
printdt "[dnf] Install Groups"
dnf group install -y \
	Editors \
	"Office/Productivity" \
	"C Development Tools and Libraries" \
	"Development Tools"
	
printdt "[dnf] Install Docker"
	printdt "[docker] Remove Existing Install of Docker"
		dnf remove -y \
			docker \
			docker-client \
			docker-client-latest \
			docker-common \
			docker-latest \
			docker-latest-logrotate \
			docker-logrotate \
			docker-selinux \
			docker-engine-selinux \
			docker-engine
		
	printdt "[docker] Install"
		dnf install -y docker-ce docker-ce-cli containerd.io

	printdt "[docker] Enable Service"
		systemctl enable --now docker

	printdt "[docker] Test"
		docker run hello-world

# Install snapd
printdt "[dnf] Install snapd"
	dnf install snapd -y
	snap install snap
	ln -s /var/lib/snapd/snap /snap
	systemctl enable --now snapd
	printdt "[snap] Version Details"
		snap version

dnf install -y curl zsh wget

# Install Python 2.x and 3.x
printdt "[dnf] Installing Python"
	dnf install -y \
		python3 \
		python2
	# Set Python2 as default
	alternatives --set python /usr/bin/python2

	printdt "[python] Downloading get-pip.py"
		rm -rf get-pip.py get-pip.p*
		wget https://bootstrap.pypa.io/get-pip.py
		printdt "[python3.x] Installing pip"
			/usr/bin/python3 get-pip.py

		printdt "[python2.x] Installing pip"
			/usr/bin/python2 get-pip.py

#Install node.js
prindt "[dnf] Installing node.js v16"
		dnf module install nodejs:16 -y

#Install ocs-url
printdt "[dnf] Install ocs-url"
	dnf install -y qt5-qtbase qt5-qtbase-gui qt5-qtsvg qt5-qtdeclarative qt5-qtquickcontrols
	dnf install -y https://REDACTED/upload/ocs-url-3.1.0-1.rpm

#Install Tools
printdt "[dnf] Installing misc stuff"
	dnf install curl dnf-plugins-core install cmake gcc clang make -y
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	dnf install -y \
		thunderbird \
		firefox \
		geany \
		java-latest-openjdk \
		lollypop \
		gnome-boxes \
		konsole \
		openvpn \
		git-cola \
		gh \
		micro \
		go \
		ruby \
		rubygem-{tk{,-doc},rake,test-unit} \
		okular \
		blender \
		ufw \
		htop \
		make \
		gcc \
		g++ \
		flatpak \
		zsh \
		cargo \
		gnome-font-viewer \
		lightdm-gtk-greeter-settings

go install github.com/nektos/act@latest

printdt "[snap] Installing packages"
	systemctl restart snapd
	snap install \
		matroska-tools \
		snap-store \
		node-red \
		beekeeper-studio \
		vlc \
		teams \
		bpytop

	snap install --classic \
		slack \
		discord \
		code
		
printdt "[flatpak] Installing packages"
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install -y \
		flathub com.spotify.Client
		
printdt "[spotify] Installing Adblock"
	rm -rf spotify-adblock
	git clone https://github.com/abba23/spotify-adblock.git
	cd spotify-adblock
	make
	
	rm -rf ~/.spotify-adblock ~/.config/spotify-adblock
	
	mkdir -p ~/.spotify-adblock 
	cp target/release/libspotifyadblock.so ~/.spotify-adblock/spotify-adblock.so
	
	mkdir -p ~/.config/spotify-adblock 
	cp config.toml ~/.config/spotify-adblock
	
	flatpak override --user --filesystem="~/.spotify-adblock/spotify-adblock.so" --filesystem="~/.config/spotify-adblock/config.toml" com.spotify.Client
	mkdir -p ~/.local/share/applications/
	rm -rf ~/.local/share/applications/Spotify.desktop
	echo "
[Desktop Entry]
Type=Application
Name=Spotify (adblock)
GenericName=Music Player
Icon=com.spotify.Client
Exec=flatpak run --file-forwarding --command=sh com.spotify.Client -c 'eval \"$(sed s#LD_PRELOAD=#LD_PRELOAD=$HOME/.spotify-adblock/spotify-adblock.so:#g /app/bin/spotify)\"' @@u %U @@
Terminal=false
MimeType=x-scheme-handler/spotify;
Categories=Audio;Music;Player;AudioVideo;
StartupWMClass=spotify
" > ~/.local/share/applications/Spotify.desktop

printdt "[oh-my-zsh] Installing"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	
printdt "========================"
printdt "Installation Complete!"
printdt "========================"
