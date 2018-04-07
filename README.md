# Dotfiles
## Installation
### Windows
1. Install gVim, Visual Studio, Python, Git for Windows, Clang, SumatraPDF and TeX Live
2. Add gVim, Python, Clang and SumatraPDF to your PATH
3. Clone the repository:
```sh
git clone https://github.com/thomasfaingnaert/dotfiles ~/dotfiles
```
4. Run Powershell as Administrator, navigate to the directory where you cloned the repository and run the script `config_win.ps1`:
```powershell
cd ~/dotfiles ; powershell -ExecutionPolicy ByPass -File .\config_win.ps1
```

### Linux
1. Clone the repository:
```sh
git clone https://github.com/thomasfaingnaert/dotfiles ~/.dotfiles
```
2. Navigate to the directory where you cloned the repository.
3. Run the `config_unix.sh` configuration script.

