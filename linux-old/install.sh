#!/bin/bash

_getdistro() {
	DISTROID=$(grep '^ID' /etc/os-release | sed 's/ID\=//g')
	if [ $(echo $DISTROID | wc -m) -lt 2 ]
	then
		echo "Unsupported Distro"
		exit 1
	fi
	return $DISTROID
}
_getdistroversion() {
	return $(grep '^VERSION_ID' /etc/os-release | sed 's/VERSION_ID\=//g')
}
_getpkman() {
	declare -A osInfo;
	osInfo[/etc/redhat-release]=dnf
	#osInfo[/etc/arch-release]=pacman
	#osInfo[/etc/gentoo-release]=emerge
	osInfo[/etc/SuSE-release]=zypp
	osInfo[/etc/debian_version]=apt

	for f in ${!osInfo[@]}
	do
		if [[ -f $f ]];then
			return $osInfo[$f]
		fi
	done
}

_isroot() {
	if [ $(whoami | grep "root" | wc -m) -lt 4 ]
	then
		return 0
	fi
	return 1
}


_install_dnf() {
	dnf install -y \
		python3 \
		python3-pip \
		wget \
		curl \
		git
}
_install_apt() {
	apt update
	apt install -y \
		python3 \
		python3-pip \
		wget \
		curl \
		git
}

if [[ $(_isroot) -lt 1 ]]
then
	echo "Run as root!"
	exit 1
fi

DISTRO = $(_getdistro)
DISTROVERSION = $(_getdistroversion)
PACKAGEMAN = $(_getpkman)
TIMESTAMP = $(date +%s)

if [[ $PACKAGEMAN = "apt" ]]
then
	_install_apt
elif [[ $PACKAGEMAN = "dnf" ]]
then
	_install_dnf
else
	echo "Unsupported Distro"
fi

wget https://bootstrap.pypa.io/get-pip.py
/usr/bin/python3 get-pip.py
rm -rf get-pip.py

wget https://github.com/ktwrd/dotfiles/raw/main/install.py
/usr/bin/python3 install.py $PACKAGEMAN $(whoami) $TIMESTAMP $DISTRO $DISTROVERSION | tee install.$TIMESTAMP.log
rm installer.py

