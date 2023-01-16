#!/bin/bash
function discordPatch()
{
	mkdir -p ~/.config/user-tmpfiles.d
	echo 'L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0' > ~/.config/user-tmpfiles.d/discord-rpc.conf
	systemctl --user enable --now systemd-tmpfiles-setup.service
}
function discordPatch_sandboxed()
{
	ln -sf "$XDG_RUNTIME_DIR/{app/com.discordapp.Discord,}/discord-ipc-0"
	# Support for vscode rich presence
	flatpak override com.visualstudio.code -u --filesystem=$XDG_RUNTIME_DIR/app/com.discordapp.Discord/
	flatpak override com.visualstudio.code -u --filesystem=$XDG_RUNTIME_DIR
}

function plexPatch()
{
	# Allow GPU access and wayland
	flatpak override tv.plex.PlexDesktop -u --sockets=wayland
	flatpak override tv.plex.PlexDesktop -u --devices=dri
}

# Patch discord rich presence to work with
# flatpak applications, sandboxed and
# non-sandboxed.
discordPatch; discordPatch_sandboxed

plexPatch;

# allow GPU access
flatpak override com.github.iwalton3.jellyfin-media-player -u --devices=dri