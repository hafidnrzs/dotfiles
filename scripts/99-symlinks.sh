#!/usr/bin/env bash
# Create symlinks from the user's home into this repo.
# Safe to re-run: existing non-symlink files are backed up to <file>.backup.<timestamp>.
source "$(dirname "$0")/lib.sh"

TS="$(date +%Y%m%d-%H%M%S)"

# link_file <source-in-repo> <target-in-home>
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        warn "Source missing, skipping: $src"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            ok "Already linked: $dst"
            return
        fi
        warn "Replacing existing symlink: $dst"
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        warn "Backing up existing file: $dst -> $dst.backup.$TS"
        mv "$dst" "$dst.backup.$TS"
    fi

    ln -s "$src" "$dst"
    ok "Linked: $dst -> $src"
}

# PROFILE selects which configs get linked:
#   desktop (default): git, fish, vscode, bashrc, shell.local
#   server           : git, bashrc, shell.local only
PROFILE="${PROFILE:-desktop}"
info "Profile: $PROFILE"

# -------- Git (always) --------
link_file "$DOTFILES_DIR/config/git/gitconfig" "$HOME/.gitconfig"

if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/config/git/gitconfig.local.example" "$HOME/.gitconfig.local"
    warn "Created ~/.gitconfig.local. Edit it to set your git identity."
fi

if [ "$PROFILE" = "desktop" ]; then
    # -------- Fish --------
    link_file "$DOTFILES_DIR/config/fish/config.fish"  "$HOME/.config/fish/config.fish"
    link_file "$DOTFILES_DIR/config/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"

    # -------- VS Code --------
    link_file "$DOTFILES_DIR/config/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    link_file "$DOTFILES_DIR/config/vscode/mcp.json"      "$HOME/.config/Code/User/mcp.json"
fi

# -------- shell.local (secrets template) --------
if [ ! -f "$HOME/.config/shell.local" ]; then
    mkdir -p "$HOME/.config"
    cp "$DOTFILES_DIR/config/shell.local.example" "$HOME/.config/shell.local"
    chmod 600 "$HOME/.config/shell.local"
    warn "Created ~/.config/shell.local. Edit it to add API keys/secrets."
fi

# -------- ~/.bashrc managed block --------
BASHRC="$HOME/.bashrc"
BLOCK_FILE="$DOTFILES_DIR/config/bash/bashrc.append"
BEGIN="# >>> dotfiles managed block >>>"
END="# <<< dotfiles managed block <<<"

if [ -f "$BASHRC" ] && [ -f "$BLOCK_FILE" ]; then
    if grep -qF "$BEGIN" "$BASHRC"; then
        info "Updating dotfiles block in ~/.bashrc..."
        # Remove existing block (portable: use a temp file)
        awk -v b="$BEGIN" -v e="$END" '
            $0 == b {skip=1; next}
            $0 == e {skip=0; next}
            !skip
        ' "$BASHRC" > "$BASHRC.tmp"
        mv "$BASHRC.tmp" "$BASHRC"
    else
        info "Appending dotfiles block to ~/.bashrc..."
    fi
    {
        echo ""
        cat "$BLOCK_FILE"
    } >> "$BASHRC"
    ok "~/.bashrc updated."
fi

ok "Symlinks & bashrc block applied."
echo
echo "-----"
echo "To add a new symlink in the future:"
echo "  1) Put the canonical config file somewhere under $DOTFILES_DIR/config/"
echo "  2) Add a link_file \"\$DOTFILES_DIR/config/<path>\" \"\$HOME/<dest>\" line"
echo "     to this script (scripts/99-symlinks.sh)."
echo "  3) Re-run: bash install.sh  (or just: bash scripts/99-symlinks.sh)"
echo "-----"
