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
    
    append_local "NVM" 'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
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

if [ -d /usr/local/go/bin ]; then
    append_local "Go" 'export PATH="/usr/local/go/bin:$PATH"'
fi

# --- Path for local binaries ---
append_local "Local bin" 'export PATH="$HOME/.local/bin:$PATH"'

# --- uv (Astral) ---
if ! have uv; then
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    ok "uv already installed."
fi

# --- PHP & Composer (Laravel) ---
if ! have php; then
    if ask "Install PHP and Composer for Laravel?" n; then
        info "Installing PHP and common extensions..."
        ensure_apt_updated
        apt_install php-cli php-common php-curl php-mbstring php-xml php-zip php-bcmath php-sqlite3 php-mysql php-pgsql php-intl php-gd

        info "Installing Composer..."
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        php -r 'copy("https://getcomposer.org/installer", "composer-setup.php");'
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            err "Composer installer corrupt!"
            rm composer-setup.php
        else
            php composer-setup.php --quiet
            rm composer-setup.php
            sudo mv composer.phar /usr/local/bin/composer
            ok "Composer installed to /usr/local/bin/composer"
        fi
    fi
else
    ok "PHP already installed: $(php -v | head -n 1)"
    if ! have composer; then
        info "PHP exists but Composer is missing. Installing Composer..."
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        ok "Composer installed."
    else
        ok "Composer already installed."
    fi
fi

# --- rtk (Rust Token Killer) ---
if ! have rtk; then
    if ask "Install rtk (Rust Token Killer)?" n; then
        info "Installing rtk to ~/.local/bin..."
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
        ok "rtk installed. Run 'rtk init -g' to enable Claude Code hook."
    fi
else
    ok "rtk already installed."
fi

# --- Kiro Integration ---
append_local "Kiro" 'if [ "$TERM_PROGRAM" = "kiro" ]; then
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
        eval "$(kiro --locate-shell-integration-path bash)"
    fi
fi'

ok "Dev tools step done."
