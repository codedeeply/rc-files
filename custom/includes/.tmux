# tmux Startup Configuration

# Allows us to decide if we want tmux at start up on a per-host basis.
# We're looking for the TMUX_ON_STARTUP variable set (default true from .allrc)

# Only run if tmux is installed
if which tmux &> /dev/null
then
  if [[ -z "$TMUX" && "$TMUX_ON_STARTUP" == "true" ]]; then
    if [[ "$ZSH_DEBUG_MODE" == "true" ]]; then
      zsh_load_msg 1 "Debug Mode is enabled! Continuing will clear screen of all log messages above."
      read -s -k '?Press any key to load tmux.'
    fi
    zsh_load_msg 0 "tmux will start after init..."
    # Defer tmux startup until after zsh init completes
    function _start_tmux_once() {
      add-zsh-hook -d precmd _start_tmux_once
      # Use xterm-256color for tmux startup (screen-256color confuses tmux)
      TERM=xterm-256color exec /opt/homebrew/bin/tmux new-session -A -s workspace
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _start_tmux_once
  elif [[ ! -z "$TMUX" && "$TMUX_ON_STARTUP" == "true" ]]; then
    zsh_load_msg 0 "tmux was supposed to fire, but was skipped because you are currently in a tmux session."
  elif [[ "$TMUX_ON_STARTUP" == "true" ]]; then
    zsh_load_msg 1 "tmux was supposed to fire, but did not. (you are not currently in a tmux session)"
  fi
else
  zsh_load_msg 1 "tmux not found. Please install tmux or set the TMUX_ON_STARTUP flag to false in your local .thisservrc file."
fi
