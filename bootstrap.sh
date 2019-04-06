#!/usr/bin/env bash

install_dotfiles()
{
    sudo apt-get install -y vim vim-gnome curl
    ./config_unix.sh
}

install_yaru()
{
    sudo snap install communitheme
    sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css /snap/communitheme/current/share/gnome-shell/theme/Communitheme/gnome-shell.css 15
    sudo sed -ie '/^\[User\]$/,/^\[/ s/^\(XSession=\).*$/\1ubuntu-communitheme-snap/' /var/lib/AccountsService/users/${USER}
}

configure_favourites()
{
    gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', 'gvim.desktop']"
}

install_dotfiles
install_yaru
configure_favourites
