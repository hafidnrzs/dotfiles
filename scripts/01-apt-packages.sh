#!/usr/bin/env bash
# Install baseline CLI packages from Ubuntu/Mint default repos (desktop profile).
source "$(dirname "$0")/lib.sh"

info "Installing baseline CLI packages (apt)..."
ensure_apt_updated

PKGS=(
    # VCS + LFS
    git git-lfs
    # Networking / download
    curl wget openssh-client rsync ufw
    # Shell + completion
    fish bash-completion
    # Archive
    zip unzip p7zip-full
    # Dev build
    build-essential make
    # Utilities
    vim htop jq tree
    # Media
    ffmpeg imagemagick
)

# flameshot is a GUI screenshot tool (pointless under WSL without WSLg)
if [ "${IS_WSL:-0}" != "1" ]; then
    PKGS+=(flameshot)
else
    info "WSL detected. Skipping flameshot (GUI tool)."
fi

apt_install "${PKGS[@]}"

# Enable git-lfs filters for the current user only (safer on shared machines)
if have git-lfs; then
    git lfs install >/dev/null 2>&1 || true
fi

# glow (charm.sh) — requires a custom APT repo
if ! have glow; then
    info "Adding charm.sh APT repository for glow..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt-get update -qq
    apt_install glow
fi

ok "Baseline CLI packages installed."
