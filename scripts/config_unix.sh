#!/usr/bin/env bash
set -Eeuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

ln -sf "$(pwd)/bash/.bashrc" ~/.bashrc
ln -sf "$(pwd)/bash/.bash_profile" ~/.bash_profile

ln -sf "$(pwd)/git/.gitattributes" ~/.gitattributes
ln -sf "$(pwd)/git/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/git/.gitignore_global" ~/.gitignore_global

ln -sf "$(pwd)/tmux/.tmux.conf" ~/.tmux.conf

ln -sf "$(pwd)/taskwarrior/.taskrc" ~/.taskrc

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

ln -sfn "$(pwd)/vim" ~/.vim
ln -sfn "$(pwd)/nvim" ~/.config/nvim

mkdir -p ~/.vim/autoload \
         ~/.vim/cache/backup \
         ~/.vim/cache/swap \
         ~/.vim/cache/undo

curl -fLsSo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if command -v nvim >/dev/null 2>&1; then
    nvim --headless +PlugInstall +qall
elif command -v vim >/dev/null 2>&1; then
    vim +PlugInstall +qall
else
    echo "Skipping Vim configuration: Vim and/or Neovim is not in PATH."
fi

mkdir -p ~/.config/gdb
ln -sf "$(pwd)/gdb/.gdbinit" ~/.gdbinit

mkdir -p ~/.config/Projecteur
ln -sf "$(pwd)/projecteur/Projecteur.conf" ~/.config/Projecteur/Projecteur.conf
