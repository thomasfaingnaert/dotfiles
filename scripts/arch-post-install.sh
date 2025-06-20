#!/usr/bin/env bash
set -Eeuo pipefail

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

# TODO: Do this with Ansible.

# TODO: Other essential packages (see wiki 2.2)
# TODO: encrypted WiFi passwords (see https://wiki.archlinux.org/title/NetworkManager)
# TODO: other networkmanager config (see https://wiki.archlinux.org/title/NetworkManager)

# Select between Qtile and Gnome.

PS3="Which DE/WM do you want to install? "

select WM in qtile gnome; do
    case "$WM" in
        qtile)
            # 3.1) Install Qtile (Wayland) as GUI.
            sudo pacman --noconfirm -S \
                qtile \
                libinput \
                python-pywayland \
                python-pywlroots \
                python-xkbcommon \
                xorg-xwayland

            # Autostart qtile on VT1.
            # NOTE: Our bash_profile from our dotfiles will source profile.local.
            cat >~/.profile.local <<EOF
            if [ -z "\$WAYLAND_DISPLAY" ] && [ -n "\$XDG_VTNR" ] && [ "\$XDG_VTNR" -eq 1 ]; then
                exec qtile start -b wayland
            fi
EOF

            # 3.3) Install a terminal.
            sudo pacman --noconfirm -S foot

            # 3.4) Create user directories automatically.
            sudo pacman --noconfirm -S xdg-user-dirs

            # 3.5) Install sounds packages (pipewire).
            sudo pacman --noconfirm -S pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber
            sudo pacman --noconfirm -S pavucontrol

            # Install a File Manager (GNOME Files).
            sudo pacman --noconfirm -S nautilus

            break
            ;;

        gnome)
            # 3.1) Install GNOME
            sudo pacman --noconfirm -S gnome

            # Autostart GDM on boot.
            sudo systemctl enable gdm

            break
            ;;
    esac
done

# 3.2) Install some fonts.
# NOTE: ttf-noto-nerd is required by bluetui.
sudo pacman --noconfirm -S noto-fonts ttf-noto-nerd

# 3.6) Install bluetooth packages (bluez).
sudo pacman --noconfirm -S bluez bluez-utils bluetui
sudo systemctl enable bluetooth

# TODO: Encryption. (+ encrypted swap, hibernation)

# TODO: zfs?

# TODO: systemd partition automounting?

# Install web browser.
sudo pacman --noconfirm -S firefox

# Install text editor.
sudo pacman --noconfirm -S nvim python-pynvim

# Install basic development packages (also required for dotfiles).
sudo pacman --noconfirm -S git base-devel

# Install dotfiles.
./scripts/config_unix.sh
