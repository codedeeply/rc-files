#!/usr/bin/env bash
# Bootstrap Sam's dotfiles on a fresh (or existing) macOS machine.
#
# Usage:
#   bash ~/configs/bootstrap.sh                    # public-only, include defaults
#   bash ~/configs/bootstrap.sh --with-private     # also symlink ssh/config from configs-private
#   bash ~/configs/bootstrap.sh --skip-defaults    # skip macos/defaults.sh
#   bash ~/configs/bootstrap.sh --dry-run          # print planned actions, don't execute
#
# Idempotent — safe to re-run.

set -euo pipefail

# ─── Flags ──────────────────────────────────────────────────────────
WITH_PRIVATE=false
SKIP_DEFAULTS=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --with-private)  WITH_PRIVATE=true ;;
    --skip-defaults) SKIP_DEFAULTS=true ;;
    --dry-run)       DRY_RUN=true ;;
    -h|--help)
      sed -n '/^# Usage/,/^# Idempotent/p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

CONFIGS="${CONFIGS:-$HOME/configs}"
CONFIGS_PRIVATE="${CONFIGS_PRIVATE:-$HOME/configs-private}"

# ─── Helpers ────────────────────────────────────────────────────────
say()   { printf '\033[1;34m[bootstrap]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[bootstrap][warn]\033[0m %s\n' "$*" >&2; }
run()   { if $DRY_RUN; then printf '  [dry-run] %s\n' "$*"; else eval "$*"; fi; }

link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    local current
    current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      printf '  ✓ %s (already linked)\n' "$dst"
      return
    fi
    warn "$dst is a symlink to $current (expected $src) — leaving alone"
    return
  fi
  if [[ -e "$dst" ]]; then
    warn "$dst exists and is not a symlink — leaving alone (move it aside and re-run)"
    return
  fi
  run "mkdir -p \"$(dirname "$dst")\""
  run "ln -s \"$src\" \"$dst\""
  printf '  + %s -> %s\n' "$dst" "$src"
}

# ─── 1. Homebrew ────────────────────────────────────────────────────
if ! command -v brew >/dev/null; then
  say "installing Homebrew"
  run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  # shellenv for the rest of this script
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
else
  say "Homebrew present ($(brew --version | head -1))"
fi

# ─── 2. brew bundle ─────────────────────────────────────────────────
if [[ -f "$CONFIGS/Brewfile" ]]; then
  say "installing from Brewfile"
  run "brew bundle --file=\"$CONFIGS/Brewfile\""
else
  warn "no Brewfile at $CONFIGS/Brewfile — skipping"
fi

# ─── 3. Public symlinks ─────────────────────────────────────────────
say "linking public dotfiles"
link "$CONFIGS/.zshenv"          "$HOME/.zshenv"
link "$CONFIGS/.zshrc"           "$HOME/.zshrc"
link "$CONFIGS/.bashrc"          "$HOME/.bashrc"
link "$CONFIGS/.tmux.conf"       "$HOME/.tmux.conf"
link "$CONFIGS/.vimrc"           "$HOME/.vimrc"
link "$CONFIGS/gitconfig"        "$HOME/.gitconfig"
link "$CONFIGS/starship.toml"    "$HOME/.config/starship.toml"
link "$CONFIGS/ghostty/config"   "$HOME/.config/ghostty/config"
# Ghostty's macOS "Settings" menu opens the Library path, not XDG — symlink it too
# so editing from either location reaches the tracked file.
link "$CONFIGS/ghostty/config"   "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
link "$CONFIGS/git/ignore"       "$HOME/.config/git/ignore"
link "$CONFIGS/nvim"             "$HOME/.config/nvim"
link "$CONFIGS/ssh/allowed_signers" "$HOME/.ssh/allowed_signers"

# ─── 4. Private symlinks (optional) ─────────────────────────────────
if $WITH_PRIVATE; then
  if [[ ! -d "$CONFIGS_PRIVATE" ]]; then
    warn "--with-private set but $CONFIGS_PRIVATE missing — clone first:"
    warn "  git clone git@github.com:codedeeply/rc-files-private.git $CONFIGS_PRIVATE"
  else
    say "linking private dotfiles"
    link "$CONFIGS_PRIVATE/ssh/config" "$HOME/.ssh/config"
    run "chmod 600 \"$CONFIGS_PRIVATE/ssh/config\""
  fi
fi

# ─── 5. Runtime dirs ────────────────────────────────────────────────
say "ensuring runtime dirs"
run "mkdir -p \"$HOME/.ssh/sockets\" && chmod 700 \"$HOME/.ssh/sockets\""

# ─── 6. .thisservrc pointer ─────────────────────────────────────────
if [[ ! -f "$CONFIGS/custom/.thisservrc" ]]; then
  warn ".thisservrc missing — copy from template:"
  warn "  cp $CONFIGS/custom/.examplethisservrc $CONFIGS/custom/.thisservrc"
  warn "  \$EDITOR $CONFIGS/custom/.thisservrc"
fi

# ─── 7. LazyVim bootstrap ───────────────────────────────────────────
if [[ ! -d "$CONFIGS/nvim" ]]; then
  say "LazyVim config missing in repo — you may need to clone the starter:"
  say "  git clone https://github.com/LazyVim/starter $CONFIGS/nvim && rm -rf $CONFIGS/nvim/.git"
fi

# ─── 8. macOS defaults ──────────────────────────────────────────────
if $SKIP_DEFAULTS; then
  say "skipping macOS defaults (--skip-defaults)"
elif [[ -x "$CONFIGS/macos/defaults.sh" ]]; then
  say "applying macOS defaults"
  run "bash \"$CONFIGS/macos/defaults.sh\""
else
  warn "$CONFIGS/macos/defaults.sh missing or not executable"
fi

# ─── Done ───────────────────────────────────────────────────────────
say "done."
cat <<EOF

Next steps:
  1. Create ~/configs/custom/.thisservrc from the example if you haven't:
       cp $CONFIGS/custom/.examplethisservrc $CONFIGS/custom/.thisservrc
  2. Open a new shell: exec zsh
  3. First zsh auto-bootstraps zinit; give it a minute.
  4. In tmux, prefix + I installs TPM plugins.
  5. In nvim, first launch bootstraps LazyVim.
EOF
