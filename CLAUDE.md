# Claude Code Context for ZSH Configs

## Repository Structure

This is a modern ZSH configuration repository using zinit, starship, and mise.

### Load Order

1. `~/.zshenv` (symlinked to `configs/.zshenv`) — sourced on every zsh
   invocation (login, interactive, scripts, cron). Sets brew shellenv,
   PATH, and tool-level env (BUN_INSTALL, PNPM_HOME).
2. `~/.zshrc` (symlinked to `configs/.zshrc`) — interactive shells only.
   Bootstraps zinit, loads plugins, inits starship, activates mise,
   then sources `custom/.thisservrc`.
3. `custom/.thisservrc` (machine-specific, git-ignored) sources in
   order:
   - `custom/.allrc` — universal settings, `zsh_load_msg`, aliases
   - `custom/.mbprc` (or other host-specific rc) — machine aliases
   - `custom/.posthostrc` — final tasks (eza, tmux auto-start, done)

### Include Files (`custom/includes/`)
- `.debugmode` — sets `ZSH_FORCE_NOTICES=true` when `ZSH_DEBUG_MODE=true`
- `.eza` — eza (ls replacement) aliases
- `.tmux` — tmux auto-start via precmd hook

## Toolchain

| Concern | Tool | How it's wired |
| --- | --- | --- |
| Plugin manager | zinit | Auto-bootstrapped in `.zshrc` on first run |
| Prompt | starship | `starship.toml` symlinked to `~/.config/starship.toml` |
| Node + Python | mise | `eval "$(mise activate zsh)"` in `.zshrc`; versions in `~/.config/mise/config.toml` |
| Syntax highlight | fast-syntax-highlighting | zinit turbo (deferred) |
| Autosuggestions | zsh-autosuggestions | zinit turbo (deferred) |
| OMZ behaviors kept | git / sudo / vi-mode | loaded as zinit snippets (`OMZP::git` etc.) |

## Important Patterns

### Boolean Variables

All boolean config variables use string comparison:
```zsh
# CORRECT
if [[ "$VAR_NAME" == "true" ]]; then

# WRONG
if [[ $VAR_NAME ]]; then      # non-empty "false" is truthy
if ( $VAR_NAME ); then        # tries to execute as command
```

### Semicolons Before `then`

Always use semicolons when `]]` and `then` are on the same line:
```zsh
# CORRECT
if [[ "$VAR" == "true" ]]; then

# WRONG — may cause parse errors
if [[ "$VAR" == "true" ]] then
```

### Startup log output goes to stderr

`zsh_load_msg` in `custom/.allrc` writes to stderr, never stdout. Any
new startup message should follow the same pattern; stdout during
shell init can break prompt integrations that snapshot terminal state.

### tmux auto-start

`custom/includes/.tmux` registers a one-shot `precmd` hook that execs
tmux after the first prompt renders. It forces `TERM=xterm-256color`
before exec because tmux otherwise inherits and refuses to start (it
reads `screen-*` as "already inside a multiplexer"). With the
`TERM=screen-256color` outer export removed from `.zshrc`, this is
still a defensive step in case some upstream environment sets it.

## Config Variables (set in `.thisservrc`)

| Variable | Type | Default | Purpose |
| --- | --- | --- | --- |
| `TMUX_ON_STARTUP` | bool | true | Auto-start tmux |
| `EZA_ON_STARTUP` | bool | true | Use eza for ls aliases |
| `ZSH_FORCE_NOTICES` | bool | false | Show NOTICE messages (honored; bug fixed) |
| `ZSH_DEBUG_MODE` | bool | false | Enable debug output (implies force-notices) |

## Common Issues

1. **Terminal closes immediately** — bad boolean check or missing `;` before `then`.
2. **tmux won't start** — check the precmd hook fires; inspect `$TERM`.
3. **Parse errors** — usually missing `}` / `;` or bad boolean syntax.
4. **Command not found** — ensure `~/.zshenv` (brew shellenv) was sourced.
5. **Prompt artifacts during startup** — something is writing to stdout during init. Move it to stderr.

## Files Not in Git

- `custom/.thisservrc` — machine-specific (use `.examplethisservrc` as template)
- `.oh-my-zsh/`, `.oh-my-zsh-custom/` — gitignored legacy scaffolding if regenerated
- `node_modules/`, `package-lock.json` — should stay untracked
