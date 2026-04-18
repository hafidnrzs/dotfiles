#!/usr/bin/env bash
# Install developer runtimes: NVM (+ Node LTS), Go, uv, rtk.
source "$(dirname "$0")/lib.sh"

# --- NVM ---
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
    info "Installing NVM..."
    PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
else
    ok "NVM already present."
fi

# Load nvm in this shell and install Node LTS
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if have nvm; then
    if ! nvm ls --no-colors | grep -q 'lts/'; then
        info "Installing Node LTS via nvm..."
        nvm install --lts
        nvm alias default 'lts/*'
    else
        ok "Node LTS already installed."
    fi
fi

# --- Go ---
if ! have go; then
    GO_VERSION="${GO_VERSION:-1.23.4}"
    info "Installing Go $GO_VERSION to /usr/local/go..."
    TMP="$(mktemp --suffix=.tar.gz)"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o "$TMP"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$TMP"
    rm -f "$TMP"
else
    ok "Go already installed: $(go version)"
fi

# --- uv (Astral) ---
if ! have uv; then
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    ok "uv already installed."
fi

# --- rtk (Rust Token Killer) ---
# Hardware/user-specific; install only if already on PATH elsewhere OR user confirms.
if ! have rtk; then
    if ask "Install rtk (Rust Token Killer)? You'll need to fetch the binary manually from its release page." n; then
        warn "Download rtk from its official releases page and place the binary at ~/.local/bin/rtk"
        warn "Repo: see your notes / https://github.com/ (project-specific)"
    fi
else
    ok "rtk already installed."
fi

ok "Dev tools step done."
