#!/usr/bin/env bash

basic_apps_and_dotfiles()
{
    sudo apt-get install -y vim vim-gnome curl
    sudo snap install skype --classic
    ./config_unix.sh
    gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Nautilus.desktop', 'gvim.desktop', 'skype_skypeforlinux.desktop']"
}

install_yaru()
{
    sudo snap install communitheme
    sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css /snap/communitheme/current/share/gnome-shell/theme/Communitheme/gnome-shell.css 15
    sudo sed -ie '/^\[User\]$/,/^\[/ s/^\(XSession=\).*$/\1ubuntu-communitheme-snap/' /var/lib/AccountsService/users/${USER}
}

configure_dualboot()
{
    timedatectl set-local-rtc 1
}

features=$(
    whiptail --title "Select Features" --checklist --notags --separate-output \
    "Choose the features to install:" 10 60 3 \
    basic       "Basic applications and dotfiles" ON \
    yaru        "Yaru theme for Ubuntu" ON \
    dualboot    "Dual boot specific configuration with Windows" ON \
    3>&1 1>&2 2>&3)

for feature in $features
do
    case $feature in
        "basic")
            basic_apps_and_dotfiles
            ;;
        "yaru")
            install_yaru
            ;;
        "dualboot")
            configure_dualboot
            ;;
    esac
done
