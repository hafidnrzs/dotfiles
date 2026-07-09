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

# --- Go (via gvm) ---
if [ ! -s "$HOME/.gvm/scripts/gvm" ]; then
    info "Installing gvm (Go Version Manager)..."
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
else
    ok "gvm already installed."
fi

# gvm's scripts assume unset variables are OK; relax -u while sourcing.
set +u
# shellcheck disable=SC1091
[ -s "$HOME/.gvm/scripts/gvm" ] && . "$HOME/.gvm/scripts/gvm"
set -u

GO_VERSION="${GO_VERSION:-go1.26.4}"
if have gvm && ! gvm list | grep -qF "$GO_VERSION"; then
    info "Installing $GO_VERSION via gvm..."
    set +u
    gvm install "$GO_VERSION" -B
    gvm use "$GO_VERSION" --default
    set -u
else
    ok "$GO_VERSION already installed via gvm."
fi

append_local "GVM (Go Version Manager)" '[ -s "$HOME/.gvm/scripts/gvm" ] && \. "$HOME/.gvm/scripts/gvm"'

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
