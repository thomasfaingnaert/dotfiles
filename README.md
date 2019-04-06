# Dotfiles
## Installation
### Windows
1. Clone the repository:
```bash
git clone https://github.com/thomasfaingnaert/dotfiles ~/dotfiles
```

2. Navigate to the directory where you cloned the repository and run the `config_win.ps1` configuration script.

### Linux
1. Install dependencies, generate an SSH key, and add it to GitHub:
```bash
sudo apt install -y git xclip && \
ssh-keygen -b 4096 && \
cat ~/.ssh/id_rsa.pub | xclip -sel c
```

2. Clone the repository, navigate to the directory where you cloned the repository and run the `bootstrap.sh` configuration script:
```bash
git clone git@github.com:thomasfaingnaert/dotfiles.git ~/.dotfiles && \
cd ~/.dotfiles && \
./bootstrap.sh
```
