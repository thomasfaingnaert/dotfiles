# Dotfiles

## Installation

### Windows

1. Clone the repository:

```bash
git clone https://github.com/thomasfaingnaert/dotfiles ~/dotfiles
```

2. Navigate to the directory where you cloned the repository and run the `config_win.ps1` configuration script.

### Linux

1. Clone the repository, navigate to the directory where you cloned the repository and run the `bootstrap.sh` configuration script:

```bash
sudo apt install -y git && \
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles && \
cd ~/.dotfiles && \
./bootstrap.sh
```

2. Generate an SSH key, and add it to GitHub:

```bash
ssh-keygen -b 4096 && \
cat ~/.ssh/id_rsa.pub | xclip -sel c
```
