$links = $(".bash_aliases", ".gitconfig", ".gitignore_global", ".minttyrc")

foreach ($link in $links)
{
    New-Item -ItemType HardLink -Path $HOME -Name $link -Value $link
}

New-Item -ItemType Junction -Path $HOME -Name vimfiles -Value vim

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

if (Get-Command "vim" -ErrorAction SilentlyContinue)
{
    vim +PlugInstall +qall
}

if (-Not (Test-Path -Path "~/.bash_profile"))
{
    $content = @'
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi
'@
    $encoding = New-Object System.Text.UTF8Encoding $False # UTF8 without BOM
    [System.IO.File]::WriteAllLines("$HOME/.bash_profile", $content, $encoding)
}

$files = @("~/vimfiles", "~/.bash_aliases", "~/.bash_history", "~/.gitconfig", "~/.gitignore_global", "~/.minttyrc", "~/_viminfo")

foreach ($file in $files)
{
    if (Test-Path $file)
    {
        $f = Get-Item $file -Force
        $f.Attributes = $f.Attributes -bor "Hidden"
    }
}

if (Test-Path 'HKCU:\Software\SimonTatham\PuTTY\Sessions')
{
    Get-ChildItem -Path 'HKCU:\Software\SimonTatham\PuTTY\Sessions' |
        ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "Colour0" -Value "101,123,131";
            Set-ItemProperty -Path $_.PSPath -Name "Colour1" -Value "88,110,117";
            Set-ItemProperty -Path $_.PSPath -Name "Colour2" -Value "253,246,227";
            Set-ItemProperty -Path $_.PSPath -Name "Colour3" -Value "238,232,213";
            Set-ItemProperty -Path $_.PSPath -Name "Colour4" -Value "238,232,213";
            Set-ItemProperty -Path $_.PSPath -Name "Colour5" -Value "101,123,131";
            Set-ItemProperty -Path $_.PSPath -Name "Colour6" -Value "7,54,66";
            Set-ItemProperty -Path $_.PSPath -Name "Colour7" -Value "0,43,54";
            Set-ItemProperty -Path $_.PSPath -Name "Colour8" -Value "220,50,47";
            Set-ItemProperty -Path $_.PSPath -Name "Colour9" -Value "203,75,22";
            Set-ItemProperty -Path $_.PSPath -Name "Colour10" -Value "133,153,0";
            Set-ItemProperty -Path $_.PSPath -Name "Colour11" -Value "88,110,117";
            Set-ItemProperty -Path $_.PSPath -Name "Colour12" -Value "181,137,0";
            Set-ItemProperty -Path $_.PSPath -Name "Colour13" -Value "101,123,131";
            Set-ItemProperty -Path $_.PSPath -Name "Colour14" -Value "38,139,210";
            Set-ItemProperty -Path $_.PSPath -Name "Colour15" -Value "131,148,150";
            Set-ItemProperty -Path $_.PSPath -Name "Colour16" -Value "211,54,130";
            Set-ItemProperty -Path $_.PSPath -Name "Colour17" -Value "108,113,196";
            Set-ItemProperty -Path $_.PSPath -Name "Colour18" -Value "42,161,152";
            Set-ItemProperty -Path $_.PSPath -Name "Colour19" -Value "147,161,161";
            Set-ItemProperty -Path $_.PSPath -Name "Colour20" -Value "238,232,213";
            Set-ItemProperty -Path $_.PSPath -Name "Colour21" -Value "253,246,227"
        }
}
