#!/bin/sh
ln -sf "$(pwd)/.bash_aliases" ~/.bash_aliases
ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/.gitignore_global" ~/.gitignore_global

ln -sfn "$(pwd)/vim" ~/.vim
ln -sfn "$(pwd)/nvim" ~/.config/nvim

mkdir -p ~/.vim/autoload \
         ~/.vim/backup \
         ~/.vim/swap \
         ~/.vim/undo

curl -fLsSo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if command -v vim >/dev/null 2>&1; then
    vim +PlugInstall +qall
else
    echo "Skipping Vim configuration: Vim is not in PATH."
fi
