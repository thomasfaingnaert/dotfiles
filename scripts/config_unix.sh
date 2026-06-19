#!/usr/bin/env bash
set -Eeuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

ln -sf "$(pwd)/bash/.bashrc" ~/.bashrc
ln -sf "$(pwd)/environment/.profile" ~/.profile

ln -sf "$(pwd)/git/.gitattributes" ~/.gitattributes
ln -sf "$(pwd)/git/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/git/.gitignore_global" ~/.gitignore_global

ln -sf "$(pwd)/tmux/.tmux.conf" ~/.tmux.conf

ln -sf "$(pwd)/taskwarrior/.taskrc" ~/.taskrc

ln -sf "$(pwd)/readline/.inputrc" ~/.inputrc

mkdir -p ~/.config/zathura
ln -sf "$(pwd)/zathura/zathurarc" ~/.config/zathura/zathurarc

mkdir -p ~/.config/timewarrior
ln -sf "$(pwd)/timewarrior/timewarrior.cfg" ~/.config/timewarrior/timewarrior.cfg

mkdir -p ~/.task/hooks
ln -sf "$(pwd)/gnome-pomodoro/taskwarrior-pomodoro-hook.py" ~/.task/hooks/on-modify.01.pomodoro

mkdir -p ~/.config/foot
ln -sf "$(pwd)/foot/foot.ini" ~/.config/foot/foot.ini

mkdir -p ~/.config/qtile
ln -sf "$(pwd)/qtile/config.py" ~/.config/qtile/config.py

mkdir -p ~/.config/gdb
ln -sf "$(pwd)/gdb/.gdbinit" ~/.gdbinit

mkdir -p ~/.config/Projecteur
ln -sf "$(pwd)/projecteur/Projecteur.conf" ~/.config/Projecteur/Projecteur.conf

mkdir -p ~/.config/keepassxc
# There are some settings we do not want to sync in Git, so just copy the file
# if it does not exist.
[[ -f ~/.config/keepassxc/keepassxc.ini ]] || cp "$(pwd)/keepassxc/keepassxc.ini" ~/.config/keepassxc/keepassxc.ini

mkdir -p ~/.config/kanshi
ln -sf "$(pwd)/kanshi/config" ~/.config/kanshi/config
