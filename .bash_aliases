alias g='git'

# Copy to/paste from clipboard
alias getclip='xclip -selection clipboard -o'
alias setclip='xclip -selection clipboard'

# Used to access git completion functions from within this script
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

# Make completion work with git alias
# Source: https://stackoverflow.com/questions/39506941/alias-g-git-and-have-bash-completion-still-work
__git_complete g _git

# Checks whether a function exists
function_exists()
{
    declare -f -F $1 >/dev/null
    return $?
}

# Add all defined git aliases as bash aliases, e.g. git co will become gco.
# Source: https://gist.github.com/EQuimper/d875df92ef0ddaabf00636c90dbc9d25
for al in $(git --list-cmds=alias); do
    alias g$al="git $al"

    # Make sure this does not break completion
    complete_func=_git_$(__git_aliased_command $al)
    function_exists $complete_func && __git_complete g$al $complete_func
done

o()
{
    if [ "$#" -eq "0" ]; then
        command xdg-open . >/dev/null 2>&1
    else
        command xdg-open "$@" >/dev/null 2>&1
    fi
}

v()
{
    num_servers=$(gvim --serverlist | wc -l)

    if [ "$num_servers" -eq "0" ]; then
        command gvim "$@"
    elif [ "$#" -eq "0" ]; then
        echo "Vim is already running"
    else
        command gvim --remote-silent "$@"
    fi
}

# Add bin/ to PATH
if [ -d ~/.dotfiles/bin ]; then
    export PATH=$PATH:~/.dotfiles/bin
elif [ -d ~/dotfiles/bin ]; then
    export PATH=$PATH:~/dotfiles/bin
fi
