#!/bin/sh
ln -sf "$(pwd)/.bash_aliases" ~/.bash_aliases
ln -sf "$(pwd)/.profile" ~/.profile
ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/.gitignore_global" ~/.gitignore_global
ln -sf "$(pwd)/.gitattributes" ~/.gitattributes
ln -sf "$(pwd)/.tmux.conf" ~/.tmux.conf
ln -sf "$(pwd)/.taskrc" ~/.taskrc

mkdir -p ~/.config/zathura
ln -sf "$(pwd)/zathurarc" ~/.config/zathura/zathurarc

mkdir -p ~/.config/timewarrior
ln -sf "$(pwd)/timewarrior.cfg" ~/.config/timewarrior/timewarrior.cfg

mkdir -p ~/.task/hooks
ln -sf "$(pwd)/taskwarrior-pomodoro-hook.py" ~/.task/hooks/on-modify.01.pomodoro

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
ln -sf "$(pwd)/.gdbinit" ~/.gdbinit

mkdir -p ~/.config/Projecteur
ln -sf "$(pwd)/Projecteur.conf" ~/.config/Projecteur/Projecteur.conf

# Comment out 'HISTSIZE' and 'HISTFILESIZE' in bashrc.
sed -i \
    -e '/^HISTSIZE=/ s/^#*/#/' \
    -e '/^HISTFILESIZE=/ s/^#*/#/' \
    ~/.bashrc
