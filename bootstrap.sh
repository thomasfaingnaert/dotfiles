#!/usr/bin/env bash

install_dotfiles()
{
    sudo apt-get install -y vim vim-gnome curl
    ./config_unix.sh
}

install_dotfiles
