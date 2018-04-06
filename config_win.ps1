cmd /c mklink /H %USERPROFILE%\.gitconfig .gitconfig
cmd /c mklink /H %USERPROFILE%\.gitignore_global .gitignore_global
cmd /c mklink /H %USERPROFILE%\.latexmkrc .latexmkrc
cmd /c mklink /H %USERPROFILE%\.minttyrc .minttyrc
md $env:LocalAppData\nvim
cmd /c mklink /H %LOCALAPPDATA%\nvim\init.vim nvim\init.vim
md $env:LocalAppData\nvim\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
    $uri,
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$env:LocalAppData\nvim\autoload\plug.vim")
)
