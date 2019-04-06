#!/bin/sh
ln -sf "$(pwd)/.bash_aliases" ~/.bash_aliases
ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/.gitignore_global" ~/.gitignore_global

ln -sfn "$(pwd)/vim" ~/.vim

mkdir ~/.vim/autoload
mkdir ~/.vim/backup
mkdir ~/.vim/swap
mkdir ~/.vim/undo

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall
