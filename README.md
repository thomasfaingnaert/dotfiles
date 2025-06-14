# Dotfiles

## Installation

### Generic Linux (dotfiles only)

1. Clone the repository, navigate to the directory where you cloned the repository and run the `scripts/config-unix.sh` script:

```bash
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles && \
cd ~/.dotfiles && \
./scripts/config-unix.sh
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
