#!/usr/bin/env bash
set -Eeuo pipefail

#############
# CONSTANTS #
#############

orange='\e[0;33m'
nc='\e[0m'
red='\e[0;31m'
green='\e[0;32m'
purple='\e[0;35m'
grey='\e[0;37m'
bold='\e[1m'
underline='\e[4m'

####################
# HELPER FUNCTIONS #
####################

print_header()
{
    local HEADER="$1"
    printf "\n$purple$bold • $HEADER\n\n$nc"
}

print_subheader()
{
    local SUBHEADER="$1"
    printf "$purple   ${underline}$SUBHEADER\n\n$nc"
}

execute()
{
    local COMMAND="$1"
    local MESSAGE="${2:-$1}"

    local errfile="$(mktemp /tmp/bootstrap-XXXXXXXX.err)"
    local exitcode=0

    # Remember start time
    local starttime=$(date +%s)

    # Run the command
    eval $COMMAND > /dev/null 2> "$errfile" &

    # Show spinner
    local pid="$!"

    local i=1
    local sp="/-\|"
    echo -n ' '

    while kill -0 "$pid" &> /dev/null; do
        spinner="${sp:i++%${#sp}:1}"
        printf "\r   $grey[$spinner] $MESSAGE$nc"
        sleep 0.2
    done
    printf "\r"

    # Check return status
    wait "$pid" || exitcode="$?"

    # Calculate running time (in seconds)
    local endtime=$(date +%s)
    local runtime=$((endtime-starttime))

    if [ "$exitcode" -eq 0 ]; then
        printf "$green   [✔] $MESSAGE ($runtime s)\n$nc"
    else
        printf "$red   [X] $MESSAGE ($runtime s)\n$nc"

        printf "$red   ┌ \n$nc"
        while read -r line; do
            printf "$red   │ $line\n$nc"
        done < "$errfile"
        printf "$red   └ \n$nc"
    fi

    rm $errfile

    return $exitcode
}

ask_question()
{
    local MESSAGE="$1"

    while true; do
        printf "$orange   [?] $MESSAGE (y/n) $nc"
        read -n1 response
        printf '\n'

        case $response in
            [Yy]) return 0;;
            [Nn]) return 1;;
            *) ;;
        esac
    done
}

prompt_sudo()
{
    # Prompt for sudo password
    print_header "Prompt for sudo password"
    sudo -v &> /dev/null

    # Keep sudo session alive
    while true; do
        sleep 300
        sudo -n true
        kill -0 "$$" || exit
    done &> /dev/null &
}

# Join array
# Source: https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
join_by() { local IFS="$1"; shift; printf "$*"; }

############
# FEATURES #
############

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
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'

    # Show battery percentage on the top bar
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    # Change PrtScr to save to clipboard by default; to save to file, use Ctrl
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "['<Ctrl>Print']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot "['<Ctrl><Alt>Print']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot "['<Ctrl><Shift>Print']"

    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot-clip "['Print']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot-clip "['<Alt>Print']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip "['<Shift>Print']"

    # Unmap default CTRL+ALT+T binding
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal '@as []'

    # Remap CTRL+ALT+T to launch terminal maximised
    # Only remap when the user has not added any mappings himself
    local current_mappings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    if [[ "${current_mappings}" == "@as []" ]]; then
        # Add custom keybind
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

        # Set the properties of the new keybind (name, command, shortcut)
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Launch terminal (maximized)'
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal --window --maximize'
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Primary><Alt>t'
    fi

    # Favourite applications
    local favorites=(
        "'firefox.desktop'"
        "'org.gnome.Nautilus.desktop'"
        "'gvim.desktop'"
        "'skype_skypeforlinux.desktop'"
        "'slack_slack.desktop'"
    )

    gsettings set org.gnome.shell favorite-apps $(printf '['; join_by ',' "${favorites[@]}"; printf ']')

    # Get default terminal profile ID
    profile=$(gsettings get org.gnome.Terminal.ProfilesList default)

    # Remove leading and trailing single quotes
    profile=${profile:1:-1}

    # Set terminal font size
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/ use-system-font false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/ font 'Ubuntu Mono Regular 18'

    # Disable 'Use colors from system theme'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/ use-theme-colors false

    # Set foreground and background colour to mimic VSCode's dark theme
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/ foreground-color 'rgb(212,212,212)'
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${profile}/ background-color 'rgb(30,30,30)'

    # Configure dash to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
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

feature_vim()
{
    # Install dependencies
    sudo apt-get install -y vim vim-gtk3
}

feature_dotfiles()
{
    # Install dependencies
    sudo apt-get install -y curl xclip

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
    # Install LLVM tools
    sudo apt-get install -y clang clangd clang-format

    # Install cmake
    sudo apt-get install -y cmake

    # Install ninja
    sudo apt-get install -y ninja-build
}

feature_screencasts()
{
    # Install peek
    sudo apt-get install -y peek

    # Install screenkey
    sudo apt-get install -y screenkey
}

feature_documents()
{
    # Install texlive
    sudo apt-get install -y texlive-full

    # Install pandoc
    sudo apt-get install -y pandoc
}

feature_docker()
{
    # Install docker
    sudo apt-get install -y docker.io
}

feature_kvm()
{
    # Install QEMU KVM
    sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

    # Install virt-manager
    sudo apt-get install -y virt-manager
}

########
# MAIN #
########

ask_for_reboot()
{
    if ask_question "Do you want to reboot?"; then
        sudo reboot
    fi
}

main()
{
    # Kill all background jobs when the shell script exits
    trap 'kill $(jobs -p) &>/dev/null' EXIT

    # Ask for sudo password
    prompt_sudo

    # Ask the user what they want to install
    features=$(
    whiptail --title "Select Features" --checklist --notags --separate-output \
        "Choose the features to install:" 21 35 14 \
        dualboot    "Dual boot fixes" ON \
        gnome       "GNOME config" ON \
        locale      "Locale settings" ON \
        vim         "Vim (repositories)" ON \
        dotfiles    "Dotfiles" ON \
        keepassxc   "KeepassXC" ON \
        skype       "Skype" ON \
        vlc         "VLC" ON \
        slack       "Slack" ON \
        cpp_dev     "C++ Development" ON \
        screencasts "Peek and Screenkey" ON \
        documents   "Document creation" ON \
        docker      "Docker" ON \
        kvm         "KVM" ON \
        3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        exit
    fi

    print_header "Install selected features"

    local i=1
    local numfeatures=$(wc -w <<< "$features")

    for feature in $features; do
        execute feature_${feature} "Feature $i of $numfeatures: $feature" || true
        i=$((i+1))
    done

    # Ask if user wants to reboot
    ask_for_reboot
}

main
