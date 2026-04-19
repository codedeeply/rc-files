# rc-files

Personal shell configuration. Modular, portable, and split so per-machine differences stay out of tracked files.

The primary shell is **zsh**; bash is supported minimally. macOS is the current target (Ghostty + tmux), but the structure is designed to accommodate other hosts via per-host include files.

## Toolchain

| Role | Tool |
| --- | --- |
| Plugin manager | [zinit](https://github.com/zdharma-continuum/zinit) (auto-bootstraps on first run) |
| Prompt | [starship](https://starship.rs) |
| Language versions (Node, Python, …) | [mise](https://mise.jdx.dev) |
| Syntax highlight | [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) (turbo-loaded) |
| Autosuggestions | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) (turbo-loaded) |
| `ls` replacement | [eza](https://eza.rocks) |
| Multiplexer | tmux (auto-started via zsh precmd hook) |
| Fuzzy finder | [fzf](https://github.com/junegunn/fzf) |

## Layout

```
configs/
├── .zshenv               → ~/.zshenv  (every zsh: PATH, brew shellenv, env)
├── .zshrc                → ~/.zshrc   (interactive: zinit, starship, mise)
├── .bashrc                           (minimal bash fallback)
├── .tmux.conf                        (tmux config)
├── starship.toml         → ~/.config/starship.toml
├── custom/
│   ├── .examplethisservrc            (template for per-host pointer)
│   ├── .thisservrc                   (PER-HOST, git-ignored — you create this)
│   ├── .allrc                        (universal aliases / functions / zsh_load_msg)
│   ├── .mbprc                        (MacBook Pro aliases)
│   ├── .posthostrc                   (final startup tasks)
│   └── includes/
│       ├── .debugmode                (ZSH_DEBUG_MODE wiring)
│       ├── .eza                      (eza aliases if installed)
│       └── .tmux                     (tmux auto-start via precmd hook)
├── .vimrc, .vim/                     (Vim)
├── .irssi/                           (IRC client)
└── CLAUDE.md                         (architecture notes for Claude / future you)
```

### Load sequence

1. `~/.zshenv` — non-interactive env (PATH, brew, BUN_INSTALL, PNPM_HOME).
2. `~/.zshrc` — interactive only. Bootstraps zinit → loads OMZ git/sudo/vi-mode snippets → turbo-loads syntax-highlight and autosuggestions → inits starship → activates mise → sources `custom/.thisservrc`.
3. `custom/.thisservrc` (per-host, git-ignored) sources `.allrc`, the host-specific rc (`.mbprc` on a MacBook Pro; add your own on other hosts), then `.posthostrc`.
4. `.posthostrc` pulls in `includes/.eza` and `includes/.tmux` (which schedules tmux for the first prompt via `add-zsh-hook precmd`).

The split means adding a new machine is: create `custom/.<hostname>rc`, update `custom/.thisservrc` to source it. No changes to tracked files needed.

## Setup on a new machine

```bash
# 1. Clone the repo where you want it (convention: ~/configs).
git clone git@github.com:codedeeply/rc-files.git ~/configs

# 2. Prereqs (macOS example).
brew install starship mise eza tmux fzf

# 3. Symlink the dotfiles that live at the top of $HOME.
ln -s ~/configs/.zshenv     ~/.zshenv
ln -s ~/configs/.zshrc      ~/.zshrc
ln -s ~/configs/.bashrc     ~/.bashrc    # optional
ln -s ~/configs/.tmux.conf  ~/.tmux.conf
ln -s ~/configs/.vimrc      ~/.vimrc
mkdir -p ~/.config && ln -s ~/configs/starship.toml ~/.config/starship.toml

# 4. Create the per-host pointer file (git-ignored).
cp ~/configs/custom/.examplethisservrc ~/configs/custom/.thisservrc
$EDITOR ~/configs/custom/.thisservrc   # tweak flags; point to the right host rc

# 5. First shell launch auto-installs zinit into ~/.local/share/zinit.
exec zsh
```

## Configuration flags (in `custom/.thisservrc`)

| Variable | Default | Purpose |
| --- | --- | --- |
| `TMUX_ON_STARTUP` | `true` | Auto-start tmux on interactive shells outside tmux |
| `EZA_ON_STARTUP` | `true` | Alias `ls`/`la` to eza if installed |
| `ZSH_FORCE_NOTICES` | `false` | Print `NOTICE`-level startup log messages |
| `ZSH_DEBUG_MODE` | `false` | Verbose startup; implies `ZSH_FORCE_NOTICES=true` |

Messages from `zsh_load_msg` go to **stderr** so they never interfere with prompt instant-prompt detection.

## Design notes

- **Don't write to stdout during shell init.** Prompts like starship and (formerly) p10k inspect terminal output and can malfunction if something prints to stdout before the first prompt. Anything chatty at startup goes to stderr.
- **Per-host files are git-ignored.** `.thisservrc` is the "pointer" that stitches together which includes to run on this machine. It's the only file you edit per-host.
- **Interactive vs non-interactive.** `.zshenv` is sourced by every zsh — including scripts and cron. Keep it cheap and side-effect-free. Heavy initialization (plugin loading, prompt, history) belongs in `.zshrc`.
- **Deferred plugin loading.** fast-syntax-highlighting and zsh-autosuggestions are turbo-loaded by zinit so they don't block the first prompt.

See [`CLAUDE.md`](./CLAUDE.md) for more detailed architecture notes, common pitfalls (boolean comparison, semicolon placement), and config-variable documentation intended for agents working in this repo.
