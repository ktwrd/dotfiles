#!/usr/bin/env bash
function backup_thingy() {
    if [ -f "$1" ]; then /bin/cp $1 $2.$current_ts; fi;
}
function copy_item() {
    if [ -L "$2" ]; then /bin/rm $2; fi
    /bin/cp $1 $2;
}
set -xeu -o pipefail
current_ts=$(date -u +%s)

backup_thingy ~/.conkyrc ./.conkyrc
backup_thingy ~/.config/fish/config.fish ./config.fish
backup_thingy ~/.config/fish/conf.d/fish_prompt.fish ./fish_prompt.fish

copy_item ./.conkyrc ~/.conkyrc
copy_item ./config.fish ~/.config/fish/config.fish
copy_item ./fish_prompt.fish ~/.config/fish/conf.d/fish_prompt.fish
