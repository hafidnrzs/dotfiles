#!/usr/bin/env bash
# Install fish + fisher + plugins, set fish as default shell.
# Keeps bash functional as fallback.
source "$(dirname "$0")/lib.sh"

if ! have fish; then
    info "Installing fish..."
    ensure_apt_updated
    apt_install fish
fi

FISH_PATH="$(command -v fish)"

# Register fish in /etc/shells if not present
if ! grep -qx "$FISH_PATH" /etc/shells; then
    info "Registering $FISH_PATH in /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Install fisher (plugin manager) inside fish
if ! fish -c 'type -q fisher' 2>/dev/null; then
    info "Installing fisher (fish plugin manager)..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fi

# Install declared plugins from fish_plugins file
PLUGINS_FILE="$DOTFILES_DIR/config/fish/fish_plugins"
if [ -f "$PLUGINS_FILE" ]; then
    info "Installing fish plugins from fish_plugins..."
    while IFS= read -r plugin; do
        [ -z "$plugin" ] && continue
        [[ "$plugin" =~ ^# ]] && continue
        fish -c "fisher install $plugin" || warn "Plugin $plugin failed"
    done < "$PLUGINS_FILE"
fi

# Set fish as default shell (but only if bash is still installed as fallback)
if ! have bash; then
    err "bash missing. Refusing to switch default shell."
    exit 1
fi

if [ "$SHELL" != "$FISH_PATH" ]; then
    if ask "Set fish as your default login shell? (bash remains available as fallback)" y; then
        chsh -s "$FISH_PATH"
        warn "Default shell changed. Log out and back in for the change to take effect."
    fi
fi

ok "Fish shell step done."
