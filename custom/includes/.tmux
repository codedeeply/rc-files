# tmux Startup Configuration

# Allows us to decide if we want tmux at start up on a per-host basis.
# We're looking for the TMUX_ON_STARTUP variable set (default true from .allrc)

# Only run if tmux is installed

# TODO BUG -- this crashes/quits the session right after starting it.
if which tmux &> /dev/null
then
  if [[ -v TMUX_ON_STARTUP ]]; then
    exec tmux new-session
  fi
else
  zsh_load_msg 1 "tmux not found. Please install tmux or set the TMUX_ON_STARTUP flag to false in your local .thisservrc file."
fi