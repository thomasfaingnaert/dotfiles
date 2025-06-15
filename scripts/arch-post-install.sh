# TODO: Do this with Ansible.

# TODO: Other essential packages (see wiki 2.2)
# TODO: encrypted WiFi passwords (see https://wiki.archlinux.org/title/NetworkManager)
# TODO: other networkmanager config (see https://wiki.archlinux.org/title/NetworkManager)

# 3.1) Install Qtile (Wayland) as GUI.
pacman --noconfirm -S \
    qtile \
    libinput \
    python-pywayland \
    python-pywlroots \
    python-xkbcommon \
    xorg-xwayland

# Autostart qtile on VT1.
# NOTE: Our bash_profile from our dotfiles will source profile.local.
cat >/~/.profile.local <<EOF
if [ -z "\$WAYLAND_DISPLAY" ] && [ -n "\$XDG_VTNR" ] && [ "\$XDG_VTNR" -eq 1 ]; then
    exec qtile start -b wayland
fi
EOF

# 3.2) Install some fonts, as installing Qtile by default doesn't pull in any.
# NOTE: ttf-noto-nerd is required by bluetui.
pacman --noconfirm -S noto-fonts ttf-noto-nerd

# 3.3) Install a terminal.
pacman --noconfirm -S foot

# 3.4) Create user directories automatically.
pacman --noconfirm -S xdg-user-dirs

# 3.5) Install sounds packages (pipewire).
pacman --noconfirm -S pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber
pacman --noconfirm -S pavucontrol

# 3.6) Install bluetooth packages (bluez).
pacman --noconfirm -S bluez bluez-utils bluetui
systemctl enable bluetooth

# TODO: general recommendations: trackpad

# TODO: Secure boot.

# TODO: Encryption. (+ encrypted swap, hibernation)

# TODO: btrfs?

# TODO: zfs?

# TODO: systemd partition automounting?

# Install web browser.
pacman --noconfirm -S firefox

# Install text editor.
pacman --noconfirm -S nvim python-pynvim

# Install basic development packages (also required for dotfiles).
pacman --noconfirm -S git base-devel

# Install dotfiles.
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles
bash ~/.dotfiles/scripts/config-unix.sh
