#!/usr/bin/env bash
# Prompt for Free Download Manager + Claude Code, then print recommended software list.
source "$(dirname "$0")/lib.sh"

# --- Free Download Manager --------------------------------------------------
echo
info "Free Download Manager is recommended before downloading other software."
if ask "Install Free Download Manager from Flathub now?" y; then
    flatpak install flathub org.freedownloadmanager.Manager
fi

# --- Claude Code ------------------------------------------------------------
echo
if ask "Install Claude Code (Anthropic's official CLI)?" y; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

cat <<'EOF'

============================================================
  Recommended software. Install manually from official sites
============================================================

These are tools the repo owner uses day-to-day. They are NOT installed
by this dotfiles bootstrap for two reasons:
  1. Each one has its own signed repo / installer. Installing them via
     a curl-piped shell script in this repo would add a supply-chain
     surface that a dotfiles repo should not own.
  2. Some of them may not be needed on every machine.

Pick what you want; every link below is the official source.

--- Browsers ---------------------------------------------------------
  Brave               https://brave.com/linux/
  Google Chrome       https://www.google.com/chrome/

--- Editors & IDEs ---------------------------------------------------
  VS Code             https://code.visualstudio.com/Download
  Obsidian            https://obsidian.md/download

--- Dev tooling ------------------------------------------------------
  Docker Engine       https://docs.docker.com/engine/install/ubuntu/
  GitHub CLI (gh)     https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  DBeaver CE          https://dbeaver.io/download/
  Bruno (API client)  https://www.usebruno.com/downloads

--- Databases --------------------------------------------------------
  MySQL Server        sudo apt install mysql-server
  PostgreSQL          sudo apt install postgresql postgresql-contrib

--- Media & utilities ------------------------------------------------
  OBS Studio          https://obsproject.com/download
  fastfetch           https://github.com/fastfetch-cli/fastfetch

--- Flatpak apps (requires `flatpak` + flathub remote) ---------------
  OnlyOffice          flatpak install flathub org.onlyoffice.desktopeditors
  Discord             flatpak install flathub com.discordapp.Discord
  Telegram            flatpak install flathub org.telegram.desktop
  Flatseal            flatpak install flathub com.github.tchx84.Flatseal
  Krita (optional)    flatpak install flathub org.kde.krita
  Kdenlive (optional) flatpak install flathub org.kde.kdenlive

--- Post-install reminders ------------------------------------------
  * After installing Docker, add yourself to the docker group:
      sudo usermod -aG docker "$USER"     (log out/in to apply)
    Note: docker group membership is effectively passwordless root.
  * After installing MySQL:
      sudo mysql_secure_installation
  * Install VS Code extensions from dotfiles:
      bash scripts/04-vscode-extensions.sh

EOF

ok "Recommendations printed."
