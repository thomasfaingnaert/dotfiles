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

    # Use 'CTRL+=' in GNOME terminal to zoom in (i.e. CTRL++, but without SHIFT)
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ zoom-in '<Primary>equal'

    # Configure dash to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

    # Only show windows of current workspace in dash to dock
    gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true

    # Make workspaces span multiple displays
    gsettings set org.gnome.mutter workspaces-only-on-primary false

    # Use Super+CTRL+arrow to switch workspaces
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Primary><Super>Up','<Primary><Super>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Primary><Super>Down','<Primary><Super>Right']"
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
    sudo apt-get install -y \
        vim                 \
        vim-gtk3
}

feature_nvim()
{
    # Install neovim
    sudo snap install nvim --classic

    # Install nvr (neovim remote)
    sudo apt-get install -y python3-pip
    pip3 install neovim-remote
}

feature_dotfiles()
{
    # Install dependencies
    sudo apt-get install -y \
        curl                \
        xclip

    # Install delta
    DELTA_URL="https://github.com/dandavison/delta/releases/download/0.5.1/git-delta_0.5.1_amd64.deb"
    DELTA_SHA="d796d3b75d690afd29fd426e7db3792724c0074b9c7b2d3aea59a3d78e735f42"

    TMPDIR="$(mktemp -d)"
    (
        cd "$TMPDIR" &&                                                   \
        wget "$DELTA_URL" &&                                              \
        echo "$DELTA_SHA $(basename "$DELTA_URL")" | sha256sum --check && \
        sudo apt-get install -y ./"$(basename "$DELTA_URL")"
    )
    rm -r "$TMPDIR"

    # Install dotfiles
    ./config_unix.sh
}

feature_skeleton()
{
    # Create directories in home
    mkdir -p ~/bin/store
    mkdir -p ~/dev/{personal,work,deps}
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
    sudo apt-get install -y vlc

    # Get MIME types for audio and video that vlc supports
    local mimetypes=$(grep '^MimeType=' /usr/share/applications/vlc.desktop | sed 's/^MimeType=//; s/;/\n/g' | grep '^\(audio\|video\)/' | tr '\n' ' ')

    # Set VLC as default audio and video player for the supported filetypes
    xdg-mime default vlc.desktop ${mimetypes}
}

feature_slack()
{
    # Install Slack
    sudo snap install slack --classic
}

feature_screencasts()
{
    sudo apt-get install -y \
        peek                \
        screenkey
}

feature_documents()
{
    sudo apt-get install -y \
        texlive-full        \
        pandoc
}

feature_docker()
{
    sudo apt-get install -y \
        docker.io           \
        docker-compose
}

feature_kvm()
{
    sudo apt-get install -y   \
        qemu-kvm              \
        libvirt-daemon-system \
        libvirt-clients       \
        bridge-utils          \
        virt-manager
}

feature_direnv()
{
    # Install direnv
    sudo apt-get install -y direnv
}

########
# MAIN #
########

usage()
{
    cat <<EOF >&2
Usage: $0 [OPTIONS]

Bootstrap script to install all software on a fresh Linux install.

Options:
-h, --help          Show this help.
-o, --off           Do not select any options by default.
EOF
}

# Default selection state for items (ON/OFF)
DEFAULT_SELECTION="ON"

parse_args()
{
    local positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage; exit 0
                ;;
            -o|--off)
                DEFAULT_SELECTION="OFF"
                shift
                ;;
            -*)
                echo "Unknown command-line option '$1'."
                echo "Try '$0 --help' for more information."
                exit 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    if [[ $# -ne 0 ]]; then
        echo "Expected 0 positional arguments, but got $#."
        echo "Try '$0 --help' for more information."
        exit 1
    fi
}

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
        "Choose the features to install:" 23 35 16                            \
        dualboot    "Dual boot fixes" "$DEFAULT_SELECTION"                    \
        gnome       "GNOME config" "$DEFAULT_SELECTION"                       \
        locale      "Locale settings" "$DEFAULT_SELECTION"                    \
        vim         "Vim (repositories)" "$DEFAULT_SELECTION"                 \
        nvim        "Neovim (snap)" "$DEFAULT_SELECTION"                      \
        dotfiles    "Dotfiles" "$DEFAULT_SELECTION"                           \
        skeleton    "Home directory skeleton" "$DEFAULT_SELECTION"            \
        keepassxc   "KeepassXC" "$DEFAULT_SELECTION"                          \
        skype       "Skype" "$DEFAULT_SELECTION"                              \
        vlc         "VLC" "$DEFAULT_SELECTION"                                \
        slack       "Slack" "$DEFAULT_SELECTION"                              \
        screencasts "Peek and Screenkey" "$DEFAULT_SELECTION"                 \
        documents   "Document creation" "$DEFAULT_SELECTION"                  \
        docker      "Docker" "$DEFAULT_SELECTION"                             \
        kvm         "KVM" "$DEFAULT_SELECTION"                                \
        direnv      "direnv" "$DEFAULT_SELECTION"                             \
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

parse_args "$@"
main
