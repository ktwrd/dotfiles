export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="seedylass"
plugins=(git ssh-agent)
source $ZSH/oh-my-zsh.sh

# Alias stuff
alias please="sudo"

please ()
{ sudo $@ }

if [ -f "micro" ]; then
    alias edit="micro"
elif [ -f "nano" ]; then
    alias edit="nano"
elif [ -f "vim" ]; then
    alias edit="vim"
elif [ -f "vi" ]; then
    alias edit="vi"
else
    edit ()
    {
        echo "No preferred editor found ;w;"
        echo "Preferred editors;"
        echo "micro, nano, vim, vi"
        exit 1
    }
fi
alias apt="sudo apt"
alias apt-get="sudo apt-get"
alias dnf="sudo dnf"
alias yum="sudo yum"
alias systemctl="/usr/bin/sudo /usr/bin/systemctl"
alias transfetch="neofetch ~/.local/share/neofetch/transflag --ascii_colors 4 5 15"

dirsize ()                                                                          
{ du -hc --max-depth=1 $@ }
