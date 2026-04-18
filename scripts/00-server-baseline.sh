#!/usr/bin/env bash
# Minimal baseline for headless/shell-only servers.
# No GUI tools, no media libs, no fish, no chsh (just the standard admin kit).
source "$(dirname "$0")/lib.sh"

info "Installing server baseline CLI packages (apt)..."
ensure_apt_updated

PKGS=(
    # VCS
    git git-lfs
    # Networking / download
    curl wget openssh-client rsync
    # Shell completion (for bash, the default)
    bash-completion
    # Archive
    zip unzip p7zip-full
    # Utilities
    vim htop jq tree
)

# ufw is useful but can lock you out of a cloud box if upstream SG/firewall
# rules are not aligned. Prompt before installing.
if ! have ufw; then
    if ask "Install ufw (host firewall)? Skip on cloud VMs that already have security groups." n; then
        PKGS+=(ufw)
    fi
fi

apt_install "${PKGS[@]}"

# git-lfs per-user only
if have git-lfs; then
    git lfs install >/dev/null 2>&1 || true
fi

ok "Server baseline installed."
