# .bashrc — minimal config for the rare bash shell (zsh is primary).
# See .zshrc / .zshenv for the main setup.

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Navigation
alias la='ls -al'

# Editor
alias vi='vim'

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# GPG: allow passphrase entry in the terminal
export GPG_TTY=$(tty)
if [[ -n "$SSH_CONNECTION" ]]; then
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi
