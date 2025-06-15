# Dotfiles

## Installation

### Generic Linux (dotfiles only)

1. Clone the repository, navigate to the directory where you cloned the repository and run the `scripts/config-unix.sh` script:

```bash
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles && \
cd ~/.dotfiles && \
./scripts/config-unix.sh
```

### Arch

1. Reset EFI Secure Boot keys (in order to enter Setup Mode).
2. Boot normal `archiso`.
3. Connect to internet (e.g. use `iwctl` and `station wlan0 connect SSID`).
4. Install `git`, clone this repository, and run the install script:

```bash
pacman -Sy git
git clone https://github.com/thomasfaingnaert/dotfiles
./dotfiles/scripts/arch-install.sh
```

### Ubuntu

1. Clone the repository, navigate to the directory where you cloned the repository and run the `scripts/ubuntu-install.sh` configuration script:

```bash
sudo apt install -y git && \
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles && \
cd ~/.dotfiles && \
./scripts/ubuntu-install.sh
```

2. Generate an SSH key, and add it to GitHub:

```bash
ssh-keygen && \
cat ~/.ssh/id_ed25519.pub | xclip -sel c
```
