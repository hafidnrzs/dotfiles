# dotfiles

Personal dotfiles for Linux/WSL2.

## Files

| File                      | Description                             |
|---------------------------|-----------------------------------------|
| `.gitconfig`              | Git global config                       |
| `.gitconfig.local.example`| Template for machine-specific git config|
| `.zshrc`                  | Zsh config (Oh My Zsh)                  |
| `.zshrc.local.example`    | Template for machine-specific zsh config|

## Install

```bash
git clone https://github.com/hafidnrzs/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

The installer will ask whether to use **zsh** or **bash**.

Choosing zsh will:
- Install zsh via the system package manager
- Install oh-my-zsh
- Install `zsh-autosuggestions` and `zsh-syntax-highlighting`
- Symlink `.zshrc` and set zsh as the default shell

## Machine-specific config

The installer will generate two local files (not tracked by git):

**`~/.gitconfig.local`** — set your identity and credential helper:
```ini
[user]
    name = Your Name
    email = your@email.com

[credential]
    # WSL: use GCM from Git for Windows
    helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
    # Linux server:
    # helper = store
```

**`~/.zshrc.local`** — enable machine-specific settings (NVM, Go, Oracle CLI, etc).
