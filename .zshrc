# .zshrc
# First file checked by ZSH for instructions.

# Check to see if .thisservrc exists...
if [[ ! -f "$HOME/configs/custom/.thisservrc" ]]; then
  printf "[ERROR] Your .thisservrc file could not be found! Ensure it's in the /configs/custom/ directory and try again. A base file can be found at ./custom/.examplethisservrc.\n"
  read -s -k '?Press any key to load stock ZSH.'
  return -1
fi

# zinit bootstrap (auto-installs on first run).
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# OMZ behaviors preserved as snippets (git aliases, sudo ESC-ESC, vi-mode).
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::vi-mode

# Syntax highlighting + autosuggestions, turbo-loaded (deferred until prompt).
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# Host config (.allrc, .mbprc, .posthostrc via .thisservrc).
source $HOME/configs/custom/.thisservrc

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Prompt
eval "$(starship init zsh)"

# nvm
export NVM_DIR="$HOME/.nvm"
 [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm
 [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# bun completions (interactive only)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Claude Code - always use Node 20 (Node 21 has SSE bug)
alias claude="/Users/sam/.nvm/versions/node/v20.19.6/bin/claude"
