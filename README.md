# Dotfiles
## Installation
### Windows
1. Clone the repository:
```bash
git clone https://github.com/thomasfaingnaert/dotfiles ~/dotfiles
```

2. Navigate to the directory where you cloned the repository and run the `config_win.ps1` configuration script.

### Linux
1. Install `git`:
```bash
sudo apt install -y git
```

2. Generate an SSH key and add it to GitHub:
```bash
ssh-keygen -b 4096
```

3. Clone the repository:
```bash
git clone git@github.com:thomasfaingnaert/dotfiles.git ~/.dotfiles
```

4. Navigate to the directory where you cloned the repository and run the `config_unix.sh` configuration script:
```bash
cd ~/.dotfiles && ./config_unix.sh
```

