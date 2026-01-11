#!/usr/bin/env bash
# Purpose: Fetch config files from YOUR install, and copy them into this repo (e.g: fish, conky, etc...)
set -xeu -o pipefail
copy_item() {
    if [ -f "$1" ]; then /bin/cp $1 ./$2; fi
}

copy_item ~/.conkyrc .conkyrc
copy_item ~/.config/fish/config.fish config.fish
copy_item ~/.config/fish/conf.d/fish_prompt.fish fish_prompt.fish