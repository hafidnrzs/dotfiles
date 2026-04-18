# dotfiles

Personal Linux setup: shell, git, and VS Code configs, plus a small
bootstrap script.

Works on **Linux Mint 22 / Ubuntu 24.04** (native or WSL2). Clone,
run `./install.sh`, answer a handful of `y/N` prompts.

```bash
git clone https://github.com/hafidnrzs/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Profiles

| Command                 | What it does                                                                   |
| ----------------------- | ------------------------------------------------------------------------------ |
| `./install.sh`          | Desktop profile: CLI baseline, fish shell, dev runtimes, all configs symlinked |
| `./install.sh --server` | Minimal CLI only + gitconfig + bashrc block (for headless servers)             |
| `./install.sh --wsl`    | Force WSL-aware mode (normally auto-detected)                                  |
| `./install.sh --help`   | Show usage                                                                     |

Every step asks `y/N` first, so it's safe to skim through and skip what you
don't want. Re-running is idempotent.

## What you get

### Desktop profile

- **Baseline CLI** (`apt`): git + git-lfs, curl, wget, openssh-client, rsync,
  ufw, fish, bash-completion, zip/unzip/p7zip, build-essential, make, vim,
  htop, jq, tree, ffmpeg, imagemagick, flameshot _(skipped on WSL)_.
- **Fish shell** as default, with `fisher` + `nvm.fish` + `bass` plugins.
  bash stays installed as fallback; both share `~/.config/shell.local`.
- **Dev runtimes**: NVM + Node LTS, Go (to `/usr/local/go`), uv (Astral).
- **Symlinks**: `~/.gitconfig`, `~/.config/fish/`, `~/.config/Code/User/`,
  plus a marker-delimited managed block appended to `~/.bashrc`.
- **Recommendation list** (printed, not auto-installed) with official
  download URLs for browsers, editors, databases, and Flatpak apps.

### Server profile

Same shell configs, without GUI libs or personal tooling:

- git, curl, rsync, openssh-client, vim/htop/jq/tree, archive tools.
- `~/.gitconfig` + `~/.bashrc` managed block + `~/.config/shell.local`
  template.
- No fish, no dev runtimes, no VS Code, no `chsh`.

## Machine-specific files (not tracked by git)

| Path                    | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| `~/.gitconfig.local`    | Git identity (name, email) + credential helper    |
| `~/.config/shell.local` | API keys / env vars sourced by both fish and bash |

Both are created from `.example` templates on first run. The git credential
helper defaults to `cache --timeout=3600` (in-memory, no plaintext on disk).

## Repo layout

```
dotfiles/
├── install.sh                   # interactive orchestrator
├── scripts/
│   ├── lib.sh                   # shared helpers (info/ok/warn/ask)
│   ├── 00-server-baseline.sh    # minimal CLI for headless
│   ├── 01-apt-packages.sh       # desktop CLI baseline
│   ├── 02-shell-fish.sh         # fish + fisher + plugins
│   ├── 03-dev-tools.sh          # NVM, Go, uv
│   ├── 04-vscode-extensions.sh  # interactive extension picker
│   ├── 05-recommendations.sh    # prints official download URLs
│   └── 99-symlinks.sh           # symlinks + bashrc managed block
└── config/
    ├── fish/{config.fish, fish_plugins}
    ├── git/{gitconfig, gitconfig.local.example}
    ├── bash/bashrc.append       # block appended to ~/.bashrc
    ├── vscode/{settings.json, mcp.json, extensions.txt}
    └── shell.local.example      # template for ~/.config/shell.local
```

## Adding a new symlink

1. Put the canonical file under `config/<category>/`.
2. Add one line to `scripts/99-symlinks.sh`:

   ```bash
   link_file "$DOTFILES_DIR/config/<category>/<file>" "$HOME/<dest>"
   ```

3. Re-run `bash scripts/99-symlinks.sh` (or the full `install.sh`).

`link_file` is idempotent: existing regular files are backed up to
`<file>.backup.<timestamp>` before the symlink replaces them; already-correct
symlinks are left alone.

## Platform notes

- **Windows native** (cmd / PowerShell / Git Bash) is not supported. The
  installer detects and exits with a pointer to WSL.
- **WSL2**: auto-detected. Repo must live under your Linux home
  (`~/dotfiles`), not under `/mnt/c/...`, because Windows filesystems
  break Linux symlinks.
- **macOS**: not supported (no apt).

## Troubleshooting

- **`chsh: fish not in /etc/shells`**. The fish step registers it. If it fails:
  ```bash
  echo "$(command -v fish)" | sudo tee -a /etc/shells
  chsh -s "$(command -v fish)"
  ```
- **Docker after install**. After running `sudo usermod -aG docker "$USER"`,
  log out and back in. Note: the `docker` group is effectively passwordless
  root; treat it that way.
- **API keys / secrets**. Put them in `~/.config/shell.local` (chmod 600).
  Both fish and bash source this file automatically.

## License

MIT. Use freely, fork, adapt, but the opinions embedded here (fish as
default, `editor = code --wait`, specific VS Code extensions) reflect my
personal setup.

Read `scripts/05-recommendations.sh` before copying the
software list wholesale.
