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
	sudo flatpak override com.visualstudio.code --filesystem=$XDG_RUNTIME_DIR/app/com.discordapp.Discord/
}

# Patch discord rich presence to work with
# flatpak applications, sandboxed and
# non-sandboxed.
discordPatch; discordPatch_sandboxed
