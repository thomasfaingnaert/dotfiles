#!/usr/bin/env bash

favorites=("'firefox.desktop'" "'org.gnome.Nautilus.desktop'")

configure_dualboot()
{
    # Make Linux store the time in local timezone instead of UTC, so the time does not jump
    # when rebooting into a different OS. This is a better solution than configuring Windows
    # to store the time in UTC.
    timedatectl set-local-rtc 1
}

ubuntu_general()
{
    # Enable click-to-minimize
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

    # Set alt-tab to switch between windows, not applications
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab','<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab','<Shift><Alt>Tab']"
}

install_yaru()
{
    # Install Yaru
    sudo snap install communitheme

    # Set GDM theme to Yaru
    sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css /snap/communitheme/current/share/gnome-shell/theme/Communitheme/gnome-shell.css 15

    # Use Yaru as default user session for the current user
    sudo sed -ie '/^\[User\]$/,/^\[/ s/^\(XSession=\).*$/\1ubuntu-communitheme-snap/' /var/lib/AccountsService/users/${USER}

    # Change cursor theme to DMZ-White
    gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
}

install_vim()
{
    # Install dependencies
    sudo apt-get install -y vim vim-gnome curl

    # Install dotfiles
    ./config_unix.sh

    # Add gVim to favorites
    favorites+=("'gvim.desktop'")
}

install_keepassxc()
{
    # Install KeepassXC
    sudo snap install keepassxc
}

install_skype()
{
    # Install Skype
    sudo snap install skype --classic

    # Add Skype to favorites
    favorites+=("'skype_skypeforlinux.desktop'")
}

install_vlc()
{
    # Install VLC
    sudo snap install vlc
}

install_slack()
{
    # Install Slack
    sudo snap install slack --classic

    # Add Slack to favorites
    favorites+=("'slack_slack.desktop'")
}

install_cpp_dev_tools()
{
    # Install C++ tools
    sudo apt-get install -y build-essential cmake checkinstall clang-7 clang-tools-7
}

install_texlive()
{
    # Install texlive
    sudo apt-get install -y texlive-full
}

install_screencasts()
{
    # Install peek
    sudo add-apt-repository ppa:peek-developers/stable
    sudo apt-get update
    sudo apt-get install -y peek

    # Install screenkey
    sudo apt-get install -y screenkey slop
}

# Join array
# Source: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local IFS="$1"; shift; printf "$*"; }


# Ask the user what they want to install
features=$(
    whiptail --title "Select Features" --checklist --notags --separate-output \
    "Choose the features to install:" 17 40 10 \
    dualboot    "Dual boot fixes" ON \
    yaru        "Yaru theme for Ubuntu" ON \
    vim         "Vim + dotfiles" ON \
    keepassxc   "KeepassXC" ON \
    skype       "Skype" ON \
    slack       "Slack" OFF \
    vlc         "VLC" ON \
    cpp         "C++ Development" ON \
    texlive     "TeX Live" OFF \
    screencasts "Peek and Screenkey" OFF \
    3>&1 1>&2 2>&3)

for feature in $features
do
    case $feature in
        "dualboot")
            configure_dualboot
            ;;
        "yaru")
            install_yaru
            ;;
        "vim")
            install_vim
            ;;
        "keepassxc")
            install_keepassxc
            ;;
        "skype")
            install_skype
            ;;
        "slack")
            install_slack
            ;;
        "vlc")
            install_vlc
            ;;
        "cpp")
            install_cpp_dev_tools
            ;;
        "texlive")
            install_texlive
            ;;
        "screencasts")
            install_screencasts
            ;;
    esac
done

# General Ubuntu config
ubuntu_general

# Set favourites
gsettings set org.gnome.shell favorite-apps $(printf '['; join_by ',' "${favorites[@]}"; printf ']')
