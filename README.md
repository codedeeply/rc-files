# rc-files

Personal dotfiles. Modular, portable, per-host differences kept out of tracked files.

Primary target: macOS (Ghostty + tmux + zsh). The structure accommodates other hosts via per-host include files.

## Two-repo architecture

| Repo | Visibility | Contents |
|---|---|---|
| [codedeeply/rc-files](https://github.com/codedeeply/rc-files) (this repo) | **Public** | Shell, tmux, Neovim, Ghostty, gitconfig, allowed_signers, Brewfile, macOS defaults, bootstrap |
| [codedeeply/rc-files-private](https://github.com/codedeeply/rc-files-private) | **Private** | `ssh/config` and anything else host-topology-sensitive |

The split exists because `~/.ssh/config` contains service-account names, tailnet hostnames, and username conventions that shouldn't be public — while the rest of the rig (prompt configs, editor setup, tool aliases) is safe to share and benefits from community visibility.

## Toolchain

| Role | Tool |
| --- | --- |
| Plugin manager | [zinit](https://github.com/zdharma-continuum/zinit) (auto-bootstraps on first run) |
| Prompt | [starship](https://starship.rs) |
| Language versions (Node, Python, …) | [mise](https://mise.jdx.dev) |
| Syntax highlight | [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) (turbo-loaded) |
| Autosuggestions | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) (turbo-loaded) |
| Editor | [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org) |
| Terminal | [Ghostty](https://ghostty.org) |
| Multiplexer | tmux (auto-started via zsh precmd hook) |
| Fuzzy finder | [fzf](https://github.com/junegunn/fzf) |
| `ls` / `cat` / `find` / `cd` / `du` / `df` | eza / bat / fd / zoxide / dust / duf |
| Diff viewer | [delta](https://github.com/dandavison/delta) (wired via gitconfig) |

## Layout

```
configs/
├── .zshenv               → ~/.zshenv    (every zsh: PATH, brew shellenv, env)
├── .zshrc                → ~/.zshrc     (interactive: zinit, starship, mise)
├── .bashrc                             (minimal bash fallback, not symlinked)
├── .tmux.conf            → ~/.tmux.conf (tmux config + catppuccin theme)
├── .vimrc                → ~/.vimrc     (legacy pure-Vim fallback)
├── starship.toml         → ~/.config/starship.toml
├── gitconfig             → ~/.gitconfig (delta, SSH signing, zdiff3, rerere)
├── ghostty/config        → ~/.config/ghostty/config
├── git/ignore            → ~/.config/git/ignore (global gitignore)
├── nvim/                 → ~/.config/nvim (LazyVim starter + overrides)
├── ssh/allowed_signers   → ~/.ssh/allowed_signers (public keys)
├── Brewfile                           (declarative package manifest)
├── bootstrap.sh                       (one-shot installer / symlinker)
├── macos/defaults.sh                  (idempotent `defaults write` script)
├── custom/
│   ├── .examplethisservrc            (template for per-host pointer)
│   ├── .thisservrc                   (PER-HOST, git-ignored — you create this)
│   ├── .allrc                        (universal aliases / zsh_load_msg)
│   ├── .mbprc                        (MacBook Pro aliases)
│   ├── .posthostrc                   (final startup tasks)
│   └── includes/
│       ├── .debugmode                (ZSH_DEBUG_MODE wiring)
│       ├── .eza                      (eza aliases if installed)
│       ├── .clitools                 (bat/fd/zoxide/dust/duf/lazygit)
│       ├── .nvim                     (vim→nvim alias + EDITOR)
│       └── .tmux                     (tmux auto-start via precmd hook)
└── CLAUDE.md                         (architecture notes for Claude / future you)
```

### Load sequence

1. `~/.zshenv` — non-interactive env (PATH, brew, BUN_INSTALL, PNPM_HOME).
2. `~/.zshrc` — interactive only. Bootstraps zinit → loads OMZ git/sudo/vi-mode snippets → turbo-loads syntax-highlight + autosuggestions → inits starship → activates mise → sources `custom/.thisservrc`.
3. `custom/.thisservrc` (per-host, git-ignored) sources `.allrc`, the host-specific rc (`.mbprc` on a MacBook Pro; add your own on other hosts), then `.posthostrc`.
4. `.posthostrc` pulls in `includes/.eza`, `.clitools`, `.nvim`, `.tmux` (tmux is scheduled for the first prompt via `add-zsh-hook precmd`).

## Setup on a new machine

```bash
# 1. Clone the public repo.
git clone git@github.com:codedeeply/rc-files.git ~/configs

# 2. (Optional) clone the private repo — needs SSH auth already set up.
git clone git@github.com:codedeeply/rc-files-private.git ~/configs-private

# 3. Run the bootstrap. Flags:
#      --with-private   — also symlink ssh/config from ~/configs-private/
#      --skip-defaults  — skip macos/defaults.sh
#      --dry-run        — print planned actions, don't execute
~/configs/bootstrap.sh --with-private

# 4. Create the per-host pointer file (git-ignored).
cp ~/configs/custom/.examplethisservrc ~/configs/custom/.thisservrc
$EDITOR ~/configs/custom/.thisservrc

# 5. First interactive shell auto-installs zinit + LazyVim plugins.
exec zsh
```

**Chicken-and-egg note for the private repo:** on a fresh machine you need an SSH key loaded (1Password SSH agent, restored from Time Machine, or copied via secure channel) before `git clone git@github.com:…` works. The public repo is also clonable via HTTPS if SSH isn't ready yet.

## Configuration flags (in `custom/.thisservrc`)

| Variable | Default | Purpose |
| --- | --- | --- |
| `TMUX_ON_STARTUP` | `true` | Auto-start tmux on interactive shells outside tmux |
| `EZA_ON_STARTUP` | `true` | Alias `ls` / `la` to eza if installed |
| `CLITOOLS_ON_STARTUP` | `true` | Enable bat / fd / zoxide / dust / duf / lazygit aliases |
| `NVIM_ALIAS_ON_STARTUP` | `false` | Alias `vim` → `nvim`, export `EDITOR=nvim` |
| `ZSH_FORCE_NOTICES` | `false` | Print `NOTICE`-level startup log messages |
| `ZSH_DEBUG_MODE` | `false` | Verbose startup; implies `ZSH_FORCE_NOTICES=true` |

Messages from `zsh_load_msg` go to **stderr** so they never interfere with prompt instant-prompt detection.

## Reproducibility

- **Brewfile** — `brew bundle --file=~/configs/Brewfile` restores every formula, cask, and tap.
- **bootstrap.sh** — idempotent symlinker + Brewfile runner + defaults applier. Safe to re-run.
- **macos/defaults.sh** — commented template of well-known `defaults write` tweaks. Uncomment what you want, re-run.
- **Commit signing** — SSH ed25519 signing key pinned in gitconfig; verified against `~/.ssh/allowed_signers`.

## Design notes

- **Don't write to stdout during shell init.** Prompts like starship inspect terminal output and can malfunction if something prints to stdout before the first prompt. Anything chatty at startup goes to stderr.
- **Per-host files are git-ignored.** `.thisservrc` stitches together which includes to run on this machine. It's the only file you edit per-host.
- **Interactive vs non-interactive.** `.zshenv` is sourced by every zsh — including scripts and cron. Keep it cheap and side-effect-free. Heavy initialization belongs in `.zshrc`.
- **Deferred plugin loading.** fast-syntax-highlighting and zsh-autosuggestions are turbo-loaded by zinit so they don't block the first prompt.
- **Two orthogonal axes.** Public-vs-sensitive (this repo vs private repo) is orthogonal to per-host (`custom/.thisservrc` pattern). A sensitive per-host file would live in the private repo.

See [`CLAUDE.md`](./CLAUDE.md) for more detailed architecture notes, common pitfalls (boolean comparison, semicolon placement), and config-variable documentation intended for agents working in this repo.
