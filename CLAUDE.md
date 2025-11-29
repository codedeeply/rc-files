# Claude Code Context for ZSH Configs

## Repository Structure

This is a ZSH configuration repository with custom modular configs.

### Load Order
1. `~/.zshrc` - Main entry point (symlinked to `configs/.zshrc`)
2. `.zshrc` sources `custom/.thisservrc` (machine-specific, git-ignored)
3. `.thisservrc` sources in order:
   - `custom/.allrc` - Universal settings and functions
   - `custom/.mbprc` (or other host-specific rc) - Machine-specific aliases
   - `custom/.posthostrc` - Final startup tasks

### Include Files (`custom/includes/`)
- `.debugmode` - Debug mode settings
- `.eza` - eza (ls replacement) configuration
- `.tmux` - tmux auto-start logic

## Important Patterns

### Boolean Variables
All boolean config variables use string comparison:
```zsh
# CORRECT
if [[ "$VAR_NAME" == "true" ]]; then

# WRONG - these cause parse errors or unexpected behavior
if [[ $VAR_NAME ]]; then      # Non-empty string "false" is truthy
if ( $VAR_NAME ); then        # Tries to execute as command
if [ $VAR_NAME ]; then        # Same issue
```

### Semicolons Before `then`
Always use semicolons when `]]` and `then` are on the same line:
```zsh
# CORRECT
if [[ "$VAR" == "true" ]]; then

# WRONG - may cause parse errors
if [[ "$VAR" == "true" ]] then
```

### tmux Startup
The tmux startup in `.tmux` uses a precmd hook to defer execution until after zsh init completes. This is necessary because:
1. The TTY isn't fully ready during zsh initialization
2. `TERM=screen-256color` (set in .zshrc) confuses tmux into thinking it's already in a multiplexer

The fix overrides TERM to `xterm-256color` when launching tmux.

## Config Variables (set in .thisservrc)

| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `TMUX_ON_STARTUP` | bool | true | Auto-start tmux |
| `EZA_ON_STARTUP` | bool | true | Use eza for ls aliases |
| `ZSH_FORCE_NOTICES` | bool | false | Show NOTICE level messages |
| `ZSH_DEBUG_MODE` | bool | false | Enable debug output |

## Common Issues

1. **Terminal closes immediately**: Check for bad boolean checks or missing semicolons
2. **tmux won't start**: Check TERM variable, ensure precmd hook is used
3. **Parse errors**: Usually missing `}`, `;`, or bad boolean syntax
4. **Commands not found**: Ensure homebrew shellenv runs before using brew packages

## Files Not in Git
- `custom/.thisservrc` - Machine-specific settings (use `.examplethisservrc` as template)
- `node_modules/`, `package-lock.json` - Should stay untracked
