#!/bin/bash
declare -A osInfo;
osInfo[/etc/redhat-release]=dnf
#osInfo[/etc/arch-release]=pacman
#osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypper
osInfo[/etc/debian_version]=apt

PKMAN=""
for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        PKMAN=${osInfo[$f]}
    fi
done

for pkg in "$@"
do
	case $pkg in
		cuda)
			case $PKMAN in
				dnf)
					dnf clean all
					dnf -y module install nvidia-driver:latest-dkms
				;;
				zypper)
					zypper refresh
				;;
				apt)
					add-apt-repository contrib
					apt-get update
				;;
			esac
	esac
done

case $PKMAN in
	dnf)
		/usr/bin/$PKMAN install -y $@
		;;
	zypper)
		/usr/bin/$PKMAN install $@
		;;
	apt)
		/usr/bin/$PKMAN install -y $@
		;;
	*)
		echo -n "Unsupported Package Manager $PKMAN"
		exit 1
		;;
esac