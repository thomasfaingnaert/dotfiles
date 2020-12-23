alias g='git'

# Copy to/paste from clipboard
alias getclip='xclip -selection clipboard -o'
alias setclip='xclip -selection clipboard'

# Remove and watch logfile
rmtail()
{
    rm $1 && touch $1 && tail -f $1
}

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
if function_exists __git_aliases; then
    aliases=$(__git_aliases)
else
    aliases=$(git --list-cmds=alias)
fi

for al in $aliases; do
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

# Prompt
# Based on Ubuntu default ~/.bashrc

red='\[\033[01;31m\]'
green='\[\033[01;32m\]'
yellow='\[\033[01;33m\]'
blue='\[\033[01;34m\]'
nc='\[\033[00m\]'

# Print return code of last command if non-zero
PS1="${red}\$(retval="\$?" ; if [[ \$retval -ne 0 ]]; then echo \"[\${retval}] \"; fi)${nc}"

# user@host:~/directory (master)$ |
PS1="${PS1}${green}\u@\h${nc}:${blue}\w${yellow}\$(__git_ps1)${nc}\$ "

# If this is an xterm set the title
# Based on Ubuntu default ~/.bashrc

title_begin="\[\e]0;"
title_end="\a\]"

case "$TERM" in
xterm*|rxvt*)
    PS1="${title_begin}\u@\h: \w${title_end}${PS1}"
    ;;
*)
    ;;
esac

# Print LLVM bitcode for CUDA
alias cuda-llvm='clang++ --cuda-gpu-arch=sm_70 --cuda-device-only -emit-llvm -S'

# Julia
alias jl='julia'

# Python
alias py='python'
