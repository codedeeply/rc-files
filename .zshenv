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
