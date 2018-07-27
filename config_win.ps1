cmd /c mklink /H %USERPROFILE%\.gitconfig .gitconfig
cmd /c mklink /H %USERPROFILE%\.gitignore_global .gitignore_global
cmd /c mklink /H %USERPROFILE%\.minttyrc .minttyrc

cmd /c mklink /J %USERPROFILE%\vimfiles vim

md -Force ~\vimfiles\autoload
md -Force ~\vimfiles\backup
md -Force ~\vimfiles\swap
md -Force ~\vimfiles\undo
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
  $uri,
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    "~\vimfiles\autoload\plug.vim"
  )
)

vim +PlugInstall +qall
