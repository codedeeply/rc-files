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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Prompt
eval "$(starship init zsh)"

# Runtime versions (replaces nvm + pyenv)
eval "$(mise activate zsh)"

# bun completions (interactive only)
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Ghostty shell integration — explicit for tmux sessions where the auto-inject
# doesn't re-run. Harmless no-op outside Ghostty.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" 2>/dev/null
fi
