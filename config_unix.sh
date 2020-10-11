#!/bin/sh
ln -sf "$(pwd)/.bash_aliases" ~/.bash_aliases
ln -sf "$(pwd)/.bash_profile" ~/.bash_profile
ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
ln -sf "$(pwd)/.gitignore_global" ~/.gitignore_global

ln -sfn "$(pwd)/vim" ~/.vim
ln -sfn "$(pwd)/nvim" ~/.config/nvim

mkdir -p ~/.vim/autoload \
         ~/.vim/cache/backup \
         ~/.vim/cache/swap \
         ~/.vim/cache/undo

curl -fLsSo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if command -v vim >/dev/null 2>&1; then
    vim +PlugInstall +qall
else
    echo "Skipping Vim configuration: Vim is not in PATH."
fi

mkdir -p ~/.julia/config
ln -sf "$(pwd)/julia/startup.jl" ~/.julia/config/startup.jl
