# Source bashrc even for interactive non-login shells.
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Add dotfiles' bin/ to PATH
if [ -d ~/.dotfiles/bin ]; then
    export PATH=$PATH:~/.dotfiles/bin
elif [ -d ~/dotfiles/bin ]; then
    export PATH=$PATH:~/dotfiles/bin
fi

# Use gvim as EDITOR for the Julia REPL
export JULIA_EDITOR='gvim --remote-silent'

# Use ninja for CMake
if command -v ninja >/dev/null 2>&1; then
    export CMAKE_GENERATOR=Ninja
fi

# Export compile commands for CMake
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

# Use vim/neovim as default EDITOR
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# Less charset
export LESSCHARSET=utf-8

# Use nvim as man pager
if command -v nvim >/dev/null 2>&1; then
    export MANPAGER='nvim +Man!'
    export MANWIDTH=999
fi

# local overrides
if [ -f "$HOME/.profile.local" ]; then
    . "$HOME/.profile.local"
fi
