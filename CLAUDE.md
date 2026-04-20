# Claude Code Context for rc-files

## Two-repo architecture

This is a **public** dotfiles repo. There is a paired **private** repo (`codedeeply/rc-files-private`) cloned to `~/configs-private/` that holds `ssh/config` — split out because it exposes tailnet hostnames, service-account keys, and internal naming conventions.

When editing files here, assume this repo is public. Do not introduce file paths, hostnames, or identifiers that would leak topology. If something feels sensitive, it probably belongs in the private repo.

## Repository structure

```
configs/
├── .zshenv, .zshrc, .bashrc   → $HOME       (shell init)
├── .tmux.conf                 → ~/.tmux.conf
├── .vimrc                     → ~/.vimrc     (legacy Vim fallback)
├── starship.toml              → ~/.config/starship.toml
├── gitconfig                  → ~/.gitconfig
├── ghostty/config             → ~/.config/ghostty/config
├── git/ignore                 → ~/.config/git/ignore (global gitignore)
├── nvim/                      → ~/.config/nvim (LazyVim + overrides)
├── ssh/allowed_signers        → ~/.ssh/allowed_signers (public-key trust list)
├── mise/config.toml           → ~/.config/mise/config.toml (runtime versions)
├── Brewfile                                  (brew bundle source)
├── bootstrap.sh                              (symlinker + installer)
├── macos/defaults.sh                         (`defaults write` template)
└── custom/                                   (host-specific rc pattern)
    ├── .examplethisservrc                    (template)
    ├── .thisservrc                           (PER-HOST, git-ignored)
    ├── .allrc, .mbprc, .posthostrc           (load in this order)
    └── includes/
        ├── .debugmode                        (ZSH_DEBUG_MODE wiring)
        ├── .eza                              (ls → eza)
        ├── .clitools                         (bat/fd/zoxide/dust/duf/lazygit)
        ├── .nvim                             (vim→nvim alias + EDITOR)
        └── .tmux                             (tmux auto-start via precmd)
```

## Load order (shell)

1. `~/.zshenv` (every zsh, including scripts/cron) — sets brew shellenv, PATH, `BUN_INSTALL`, `PNPM_HOME`. Keep cheap and side-effect-free.
2. `~/.zshrc` (interactive only) — bootstraps zinit, loads OMZ git/sudo/vi-mode snippets, turbo-loads syntax-highlight + autosuggestions, inits starship, activates mise, then sources `custom/.thisservrc`.
3. `custom/.thisservrc` sources `.allrc` → `.<host>rc` → `.posthostrc`.
4. `.posthostrc` pulls in (in order) `includes/.eza`, `.clitools`, `.nvim`, `.tmux`.

## Toolchain

| Concern | Tool | Wiring |
| --- | --- | --- |
| Plugin manager | zinit | Auto-bootstrapped in `.zshrc` on first run |
| Prompt | starship | `starship.toml` symlinked to `~/.config/starship.toml` |
| Runtime versions (Node/Python) | mise | `mise activate zsh` in `.zshrc`; versions in `configs/mise/config.toml` |
| Syntax highlight | fast-syntax-highlighting | zinit turbo (deferred) |
| Autosuggestions | zsh-autosuggestions | zinit turbo (deferred) |
| OMZ behaviors | git / sudo / vi-mode | zinit snippets (`OMZP::git` etc.) |
| Editor | Neovim + LazyVim | `nvim/` symlinked; overrides under `nvim/lua/plugins/` |
| Terminal | Ghostty | `ghostty/config` symlinked |
| Multiplexer | tmux + TPM | precmd-based auto-start, catppuccin theme |
| Diff viewer | delta | Wired via `gitconfig` `core.pager` |
| Commit signing | SSH ed25519 | Key lives in 1Password (SSH vault); `gpg.ssh.program = op-ssh-sign` in `gitconfig`; `allowed_signers` tracked here |
| SSH agent | 1Password | Agent socket exported in `.zshenv` as `SSH_AUTH_SOCK`; vault authorization in `~/.config/1Password/ssh/agent.toml` (not tracked — per-machine) |

## Reproducibility scripts

- `bootstrap.sh` — one-shot installer. Installs Homebrew if missing, runs `brew bundle`, creates every symlink (idempotent — detects existing-correct symlinks, warns on collisions, never clobbers). Flags: `--with-private` (links `ssh/config` from `~/configs-private/`), `--skip-defaults`, `--dry-run`.
- `Brewfile` — `brew bundle dump` output. Regenerate with `brew bundle dump --force --file=~/configs/Brewfile`.
- `macos/defaults.sh` — commented-out `defaults write` menu. Uncomment and re-run as needed.

## Important patterns

### Boolean variables (string compared)

```zsh
if [[ "$VAR_NAME" == "true" ]]; then   # CORRECT
if [[ $VAR_NAME ]]; then                # WRONG — non-empty "false" is truthy
```

### Semicolons before `then`

```zsh
if [[ "$VAR" == "true" ]]; then   # CORRECT
if [[ "$VAR" == "true" ]] then    # WRONG — parse error
```

### Startup output → stderr only

`zsh_load_msg` in `custom/.allrc:14-36` writes to stderr. Any new startup message must follow the same pattern; stdout during shell init breaks prompt instant-prompt detection (starship, p10k).

### tmux auto-start

`custom/includes/.tmux` registers a one-shot `precmd` hook that execs tmux after the first prompt. Forces `TERM=xterm-256color` before exec because tmux refuses to start when `TERM=screen-*` (it thinks it's already in a multiplexer).

### Include files gate on opt-in flag

Pattern: each include in `custom/includes/` starts with `if [[ "$<TOOL>_ON_STARTUP" != "true" ]]; then return 0; fi`, so features can be toggled per-host via `.thisservrc` without editing tracked files. Missing tools are warned via `zsh_load_msg 1 "…"`.

## Config variables (set in `.thisservrc`)

| Variable | Default | Purpose |
| --- | --- | --- |
| `TMUX_ON_STARTUP` | true | Auto-start tmux on interactive shells |
| `EZA_ON_STARTUP` | true | `ls` / `la` aliased to eza |
| `CLITOOLS_ON_STARTUP` | true | bat / fd / zoxide / dust / duf / lazygit aliases |
| `NVIM_ALIAS_ON_STARTUP` | false (example) / true (mbp) | `vim`/`vi` → `nvim`, `EDITOR=nvim` |
| `ZSH_FORCE_NOTICES` | false | Show `NOTICE`-level startup log messages |
| `ZSH_DEBUG_MODE` | false | Verbose startup; implies `ZSH_FORCE_NOTICES=true` |

## Common issues

1. **Terminal closes immediately on launch** — bad boolean check or missing `;` before `then` in one of the includes or `.thisservrc`.
2. **tmux won't start** — inspect `$TERM`; the precmd hook forces `xterm-256color` before exec.
3. **Parse errors** — usually missing `}` / `;` or a bare `if [[ $VAR ]]` boolean check.
4. **Command not found** — `~/.zshenv` didn't source `brew shellenv`; check PATH.
5. **Prompt artifacts during startup** — something printed to stdout during init. Move to stderr via `zsh_load_msg`.
6. **mise says "not trusted"** — run `mise trust ~/configs/mise/config.toml` once after a fresh clone (the symlinked path must be trusted).
7. **LazyVim / Mason plugin repo renamed** — update `nvim/lua/plugins/lsp.lua` ensure_installed/plugin spec when upstream repos move.

## Files not in git

- `custom/.thisservrc` — per-host (use `.examplethisservrc` as template).
- `custom/.<host>rc` — only tracked if the host rc is reusable across machines (e.g. `.mbprc` is generic Mac, but a specific laptop's private aliases should live in an untracked file or the private repo).
- `node_modules/`, `package-lock.json`, `.oh-my-zsh*/` — legacy / tooling noise.
- `.vim/plugged/` — vim-plug plugin dir, runtime only.
