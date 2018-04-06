cmd /c mklink /H %USERPROFILE%\.gitconfig .gitconfig
cmd /c mklink /H %USERPROFILE%\.gitignore_global .gitignore_global
cmd /c mklink /H %USERPROFILE%\.latexmkrc .latexmkrc
cmd /c mklink /H %USERPROFILE%\.minttyrc .minttyrc
mkdir $env:LocalAppData\nvim
cmd /c mklink /H %LOCALAPPDATA%\nvim\init.vim nvim\init.vim
