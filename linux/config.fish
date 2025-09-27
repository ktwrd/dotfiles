if status is-interactive
    # Commands to run in interactive sessions can go here
end
set fish_greeting

set --export LIBVIRT_DEFAULT_URI "qemu:///system"
set --export LESS '-R'
set --export LESSOPEN '|~/.lessfilter %s'

# deno
set --export DENO_INSTALL "$HOME/.deno"
set --export PATH $DENO_INSTALL/bin $PATH
#alias protontricks='flatpak run com.github.Matoking.protontricks'
#alias protontricks-launch='flatpak run --command=protontricks-launch com.github.Matoking.protontricks'

# .net
# export PATH="$PATH:$HOME/.dotnet/tools"
set --export PATH $HOME/.dotnet/tools $PATH

# rust
set --export SENTRY_URL "https://sentry.kate.pet"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
