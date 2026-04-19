#!/usr/bin/env bash
# macOS defaults — idempotent. Safe to re-run.
#
# Uncomment the options you want. Run with:
#   bash ~/configs/macos/defaults.sh
#
# Some changes need a logout/reboot or app restart to take effect; the script
# kills the affected apps at the end of each section where applicable.

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "macos/defaults.sh: not macOS, skipping." >&2
  exit 0
fi

echo "Applying macOS defaults…"

# ─── Finder ─────────────────────────────────────────────────────────
# defaults write com.apple.finder AppleShowAllFiles -bool true          # show hidden files
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true       # show all file extensions
# defaults write com.apple.finder ShowPathbar -bool true                # show path bar
# defaults write com.apple.finder ShowStatusBar -bool true              # show status bar
# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view in new windows
# defaults write com.apple.finder _FXSortFoldersFirst -bool true        # folders first when sorting
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true   # no .DS_Store on network
# defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true       # no .DS_Store on USB

# ─── Dock ───────────────────────────────────────────────────────────
# defaults write com.apple.dock autohide -bool true                     # auto-hide
# defaults write com.apple.dock autohide-delay -float 0                 # no hide delay
# defaults write com.apple.dock autohide-time-modifier -float 0.15      # fast slide
# defaults write com.apple.dock tilesize -int 44                        # icon size
# defaults write com.apple.dock show-recents -bool false                # no recent apps
# defaults write com.apple.dock orientation -string "bottom"            # position
# defaults write com.apple.dock mru-spaces -bool false                  # don't reorder spaces

# ─── Keyboard ───────────────────────────────────────────────────────
# defaults write NSGlobalDomain KeyRepeat -int 2                        # fast key repeat
# defaults write NSGlobalDomain InitialKeyRepeat -int 15                # short delay before repeat
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false    # disable accented-char popup
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3              # full keyboard control

# ─── Trackpad ───────────────────────────────────────────────────────
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true   # tap to click
# defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ─── Screenshots ────────────────────────────────────────────────────
# mkdir -p "$HOME/Screenshots"
# defaults write com.apple.screencapture location -string "$HOME/Screenshots"
# defaults write com.apple.screencapture type -string "png"
# defaults write com.apple.screencapture disable-shadow -bool true

# ─── Safari ─────────────────────────────────────────────────────────
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# ─── TextEdit ───────────────────────────────────────────────────────
# defaults write com.apple.TextEdit RichText -int 0                     # plain text default
# defaults write com.apple.TextEdit PlainTextEncoding -int 4            # UTF-8
# defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ─── Menu bar ───────────────────────────────────────────────────────
# defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"

# ─── Terminal-adjacent (non-Ghostty apps) ───────────────────────────
# defaults write com.apple.terminal StringEncodings -array 4            # UTF-8 in Terminal.app

# ─── App restarts ───────────────────────────────────────────────────
# Uncomment to restart apps whose defaults you changed above.
# for app in Finder Dock SystemUIServer; do
#   killall "$app" &>/dev/null || true
# done

echo "macOS defaults applied."
