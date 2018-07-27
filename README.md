# Dotfiles
## Installation
### Windows
1. Clone the repository:
```sh
git clone https://github.com/thomasfaingnaert/dotfiles ~/dotfiles
```

2. Run Powershell as Administrator, navigate to the directory where you cloned the repository and run the script `config_win.ps1`:
```powershell
cd ~/dotfiles ; powershell -ExecutionPolicy ByPass -File .\config_win.ps1
```

### Linux
1. Clone the repository:
```sh
git clone git@github.com:thomasfaingnaert/dotfiles.git ~/.dotfiles
```

2. Navigate to the directory where you cloned the repository and run the `config_unix.sh` configuration script:
```sh
cd ~/.dotfiles && ./config_unix.sh
```

