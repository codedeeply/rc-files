# .zshenv — sourced for every zsh invocation (login, interactive, script).
# Keep this fast and side-effect-free. No prompts, no eval of slow tools.

# Homebrew (must be first — downstream PATHs depend on $HOMEBREW_PREFIX).
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH: dedupe automatically, prepend user dirs in a defined order.
typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$HOME/.opencode/bin"
  "$HOME/Library/pnpm"
  "$HOME/.spicetify"
  "$HOME/.cache/lm-studio/bin"
  $path
)
export PATH

# Tool-specific env
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

# 1Password SSH agent — served from the 1P.app socket; git/ssh/gh honor this var.
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
