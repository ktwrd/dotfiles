export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="seedylass"
plugins=(git ssh-agent)
source $ZSH/oh-my-zsh.sh

# Alias stuff
alias please="/usr/bin/sudo"
alias edit="/usr/bin/micro"
alias apt="/usr/bin/sudo /usr/bin/apt-get"
alias systemctl="/usr/bin/sudo /usr/bin/systemctl"
alias transfetch="neofetch ~/.local/share/neofetch/transflag --ascii_colors 4 5 15"
