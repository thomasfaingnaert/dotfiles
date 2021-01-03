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

# Utility functions to manage symlinks in ~/bin.

# Garbage collection: remove dangling
bin-gc()
{
    usage()
    {
        cat <<EOF >&2
Usage: bin-gc [OPTIONS]

Remove dangling symlinks from ~/bin.

Options:
-h, --help          Show this help.
-n, --dry-run       Only show what would be removed, but do not actually remove anything.
-f, --force         bin-gc will refuse to remove anything unless this option is given.
EOF
    }

    local dry_run=false
    local force=false

    local positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage; return 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -*)
                echo "Unknown command-line option '$1'."
                echo "Try 'bin-gc --help' for more information."
                return 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    if [[ $# -ne 0 ]]; then
        echo "Expected 0 positional arguments, but got $#."
        echo "Try 'bin-gc --help' for more information."
        return 1
    fi

    if [[ "$dry_run" = true ]]; then
        find ~/bin -maxdepth 1 -xtype l
        return 0
    elif [[ "$force" = true ]]; then
        find ~/bin -maxdepth 1 -xtype l -delete
        return 0
    else
        usage; return 1
    fi
}

# Rm: remove symlinks
bin-rm()
{
    usage()
    {
        cat <<EOF >&2
Usage: bin-rm [OPTIONS] <DIRECTORY>

Remove all symlinks from ~/bin that point to the given DIRECTORY.

Options:
-h, --help          Show this help.
-n, --dry-run       Only show what would be removed, but do not actually remove anything.
EOF
    }

    local dry_run=false

    local positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage; return 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -*)
                echo "Unknown command-line option '$1'."
                echo "Try 'bin-rm --help' for more information."
                return 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    if [[ $# -ne 1 ]]; then
        echo "Expected 1 positional argument, but got $#."
        echo "Try 'bin-rm --help' for more information."
        return 1
    fi

    local directory="$(readlink -f "$1")"

    if [[ "$dry_run" = true ]]; then
        find ~/bin -maxdepth 1 -type l -print0 |
            while IFS= read -r -d '' f; do
                if [[ "$(readlink -f $f)" == ${directory}/* ]]; then
                    echo $f
                fi
            done
        return 0
    else
        find ~/bin -maxdepth 1 -type l -print0 |
            while IFS= read -r -d '' f; do
                if [[ "$(readlink -f $f)" == ${directory}/* ]]; then
                    rm $f
                fi
            done
        return 0
    fi
}

# Add: add symlinks
bin-add()
{
    usage()
    {
        cat <<EOF >&2
Usage: bin-add [OPTIONS] <PATH...>

Add symlinks to ~/bin.

Options:
-h, --help              Show this help.
-n, --dry-run           Only show what would be added, but do not actually add anything.
-p, --prefix PREFIX     Prefix to add before every symlink's name (default is empty string).
-s, --suffix SUFFIX     Suffix to add after every symlink's name (default is empty string).
EOF
    }

    local dry_run=false
    local prefix=""
    local suffix=""

    local positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage; return 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -p|--prefix)
                prefix=$2
                shift; shift
                ;;
            -s|--suffix)
                suffix=$2
                shift; shift
                ;;
            -*)
                echo "Unknown command-line option '$1'."
                echo "Try 'bin-add --help' for more information."
                return 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    if [[ $# -eq 0 ]]; then
        echo "Expected at least one positional argument, but got $#."
        echo "Try 'bin-add --help' for more information."
        return 1
    fi

    if [[ "$dry_run" = true ]]; then
        for path in "$@"; do
            find "$path" -type f -executable
        done
    else
        for path in "$@"; do
            find "$path" -type f -executable -exec sh -c "ln -rs \$(readlink -f {}) ~/bin/${prefix}\$(basename {})${suffix}" \;
        done
    fi
}

# Ls: list symlinks
bin-ls()
{
    usage()
    {
        cat <<EOF >&2
Usage: bin-ls [OPTIONS]

List symlinks in ~/bin.

Options:
-h, --help          Show this help.
EOF
    }

    positional=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage; return 0
                ;;
            -*)
                echo "Unknown command-line option '$1'."
                echo "Try 'bin-ls --help' for more information."
                return 1
                ;;
            *)
                positional+=("$1")
                shift
                ;;
        esac
    done
    set -- "${positional[@]}"

    if [[ $# -ne 0 ]]; then
        echo "Expected 0 positional arguments, but got $#."
        echo "Try 'bin-ls --help' for more information."
        return 1
    fi

    local bold_cyan="\033[1;36m"
    local bold_green="\033[1;32m"
    local nc="\033[0m"
    local filename_width=40

    find ~/bin -maxdepth 1 -type l -printf "${bold_cyan}%-${filename_width}P${nc} -> ${bold_green}%l\n" | sort -k 3 | less -R
}

# direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
