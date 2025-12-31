#!/usr/bin/env bash
#/bin/cp ./.conkyrc ~/
#/bin/cp ./1_config.fish ~/.config/fish/conf.d/
#/bin/cp ./2_fish_prompt.fish ~/.config/fish/conf.d/

current_ts=$(date -u +%s)

function backup_thingy() {
    if [ -f "$1" ]; then
        /bin/cp $1 $2.$current_ts
        echo "---created backup---"
        echo "from: $1"
        echo "  to: $2"
    fi
}

backup_thingy ~/.conkyrc ./.conkyrc
backup_thingy ~/.config/fish/conf.d/config.fish ./config.fish
backup_thingy ~/.config/fish/conf.d/fish_prompt.fish ./fish_prompt.fish


ln -sf ./.conkyrc ~/.conkyrc
ln -sf ./config.fish ~/.config/fish/conf.d/config.fish
ln -sf ./fish_prompt.fish ~/.config/fish/conf.d/fish_prompt.fish

