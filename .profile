# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
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

# Use clang as a compiler (if in path)
if command -v clang >/dev/null 2>&1; then
    export CC=clang
fi

if command -v clang++ >/dev/null 2>&1; then
    export CCX=clang++
fi

# local overrides
if [ -f "$HOME/.profile.local" ]; then
    . "$HOME/.profile.local"
fi
