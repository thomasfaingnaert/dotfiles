# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# Add some directories in my home directory to the PATH.
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="$HOME/.dotfiles/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

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
