#!/usr/bin/env bash

favorites=(
    "'firefox.desktop'"
    "'org.gnome.Nautilus.desktop'"
    "'gvim.desktop'"
    "'skype_skypeforlinux.desktop'"
    "'slack_slack.desktop'"
)

feature_dualboot()
{
    # Make Linux store the time in local timezone instead of UTC, so the time does not jump
    # when rebooting into a different OS. This is a better solution than configuring Windows
    # to store the time in UTC.
    timedatectl set-local-rtc 1

    # GRUB configuration
    sudo sed -i \
             -e 's/^GRUB_TIMEOUT=[0-9]*$/GRUB_TIMEOUT=5/' \
             -e 's/^GRUB_DEFAULT=.*$/GRUB_DEFAULT=saved/' \
             /etc/default/grub

    if ! grep -q '^GRUB_SAVEDEFAULT=true' /etc/default/grub; then
        printf "\nGRUB_SAVEDEFAULT=true\n" | sudo tee -a /etc/default/grub >/dev/null
    fi

    sudo update-grub
}

feature_gnome()
{
    # Enable click-to-minimize
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

    # Show battery percentage on the top bar
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    # Set alt-tab to switch between windows, not applications
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab','<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab','<Shift><Alt>Tab']"

    # Change PrtScr to save to clipboard by default; to save to file, use Ctrl
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '<Ctrl>Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot '<Ctrl><Alt>Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot '<Ctrl><Shift>Print'

    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot-clip 'Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot-clip '<Alt>Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip '<Shift>Print'
}

feature_locale()
{
    local LOCALE="en_GB.UTF-8"

    # Set user locale
    dbus-send --system --dest=org.freedesktop.Accounts /org/freedesktop/Accounts/User${UID} org.freedesktop.Accounts.User.SetFormatsLocale string:"${LOCALE}"

    # Set system wide locale
    sudo update-locale LC_NUMERIC="${LOCALE}" \
                       LC_TIME="${LOCALE}" \
                       LC_MONETARY="${LOCALE}" \
                       LC_PAPER="${LOCALE}" \
                       LC_NAME="${LOCALE}" \
                       LC_ADDRESS="${LOCALE}" \
                       LC_TELEPHONE="${LOCALE}" \
                       LC_MEASUREMENT="${LOCALE}" \
                       LC_IDENTIFICATION="${LOCALE}"
}

feature_yaru()
{
    # Install Yaru
    sudo snap install communitheme

    # Set GDM theme to Yaru
    sudo update-alternatives --install /usr/share/gnome-shell/theme/gdm3.css gdm3.css /snap/communitheme/current/share/gnome-shell/theme/Communitheme/gnome-shell.css 15

    # Use Yaru as default user session for the current user
    sudo sed -i '/^\[User\]$/,/^\[/ s/^\(XSession=\).*$/\1ubuntu-communitheme-snap/' /var/lib/AccountsService/users/${USER}

    # Change cursor theme to DMZ-White
    gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
}

feature_vim()
{
    # Install dependencies
    sudo apt-get install -y vim vim-gnome
}

feature_vim_git()
{
    # Create a directory to store .desktop files, if it doesn't exist already
    sudo mkdir -p /usr/local/share/applications

    # Install dependencies
    sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev \
        python3-dev

    # Get the python3 config dir
    local python3_version=$(python3 --version | sed 's/[^0-9]*\([0-9]*\.[0-9]*\).*/\1/')
    local python3_config_dir="/usr/lib/python${python3_version}/config-${python3_version}m-x86_64-linux-gnu"

    if [ ! -d "${python3_config_dir}" ]; then
        echo "Python 3 configuration directory '${python3_config_dir}' not found!"
        return
    fi

    # Clone Vim repository
    mkdir -p ~/src
    pushd ~/src
    git clone https://github.com/vim/vim.git vim
    cd vim

    # What Vim version are we building?
    local git_tag=$(git describe --abbrev=0 --tags) # v8.1.1000
    local vim_version=$(echo ${git_tag} | sed 's/^[^0-9]//') # 8.1.1000
    local vim_short_version=$(echo ${vim_version} | sed 's/^\([0-9]*\)\.\([0-9]*\).*/\1\2/') # 81

    # Config, compilation and install
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-python3interp=yes \
                --with-python3-config-dir=${python3_config_dir} \
                --enable-gui=gtk2 \
                --enable-cscope \
                --prefix=/usr/local

    make -j$(nproc) VIMRUNTIMEDIR=/usr/local/share/vim/vim${vim_short_version}

    sudo apt-get install -y checkinstall
    cat >description-pak <<EOF
Vi IMproved - enhanced vi editor - with GUI (compiled from source)
EOF

    sudo checkinstall -y --pkgname vim-git --pkgversion "${vim_version}" --maintainer "Thomas Faingnaert" --provides vim

    # Set compiled Vim as default
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    sudo update-alternatives --set editor /usr/local/bin/vim
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    sudo update-alternatives --set vi /usr/local/bin/vim

    # Get rid of warning when starting gvim
    sudo apt-get install -y libcanberra-gtk-module

    # Restore current working directory
    popd
}

feature_neovim_git()
{
    # Install dependencies
    sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf \
                            automake cmake g++ pkg-config unzip

    # Clone Neovim repository
    mkdir -p ~/src
    pushd ~/src
    git clone https://github.com/neovim/neovim neovim
    cd neovim

    # Compilation and installation
    make -j$(nproc) CMAKE_BUILD_TYPE=RelWithDebInfo

    sudo apt-get install -y checkinstall
    cat >description-pak <<EOF
Neovim (compiled from source)
EOF

    sudo checkinstall -y --pkgname neovim-git --pkgversion "1.0" --maintainer "Thomas Faingnaert" --provides neovim

    # Restore current working directory
    popd

    # Install GUI
    sudo apt-get install -y neovim-qt
}

feature_dotfiles()
{
    # Install dependencies
    sudo apt-get install -y curl

    # Install dotfiles
    ./config_unix.sh
}

feature_keepassxc()
{
    # Install KeepassXC
    sudo snap install keepassxc
}

feature_skype()
{
    # Install Skype
    sudo snap install skype --classic
}

feature_vlc()
{
    # Install VLC
    sudo snap install vlc

    # Get MIME types for audio and video that vlc supports
    local mimetypes=$(grep '^MimeType=' /var/lib/snapd/desktop/applications/vlc_vlc.desktop | sed 's/^MimeType=//; s/;/\n/g' | grep '^\(audio\|video\)/' | tr '\n' ' ')

    # Set VLC as default audio and video player for the supported filetypes
    xdg-mime default vlc_vlc.desktop ${mimetypes}
}

feature_slack()
{
    # Install Slack
    sudo snap install slack --classic
}

feature_cpp_dev()
{
    # Install C++ tools
    sudo apt-get install -y build-essential cmake checkinstall clang-7 clang-tools-7
}

feature_screencasts()
{
    # Install peek
    sudo add-apt-repository -y ppa:peek-developers/stable
    sudo apt-get update
    sudo apt-get install -y peek

    # Install screenkey
    sudo apt-get install -y screenkey slop
}

feature_texlive()
{
    # Install texlive
    sudo apt-get install -y texlive-full
}

# Join array
# Source: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local IFS="$1"; shift; printf "$*"; }

# Ask the user what they want to install
features=$(
whiptail --title "Select Features" --checklist --notags --separate-output \
    "Choose the features to install:" 22 35 15 \
    dualboot    "Dual boot fixes" ON \
    gnome       "GNOME config" ON \
    locale      "Locale settings" ON \
    yaru        "Yaru theme for Ubuntu" ON \
    vim         "Vim (repositories)" ON \
    vim_git     "Vim (from source)" OFF \
    neovim_git  "Neovim (from source)" OFF \
    dotfiles    "Dotfiles" ON \
    keepassxc   "KeepassXC" ON \
    skype       "Skype" ON \
    vlc         "VLC" ON \
    slack       "Slack" OFF \
    cpp_dev     "C++ Development" ON \
    screencasts "Peek and Screenkey" OFF \
    texlive     "TeX Live" OFF \
    3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
    exit
fi

for feature in $features; do
    feature_${feature}
done

# Set favourites
gsettings set org.gnome.shell favorite-apps $(printf '['; join_by ',' "${favorites[@]}"; printf ']')
