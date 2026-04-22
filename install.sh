#!/usr/bin/env bash
# Dotfiles installer (Linux Mint/Ubuntu (native or WSL2)).
# Interactive: prompts y/N per category, dispatches to scripts/.
#
# Usage:
#   ./install.sh              # full desktop profile
#   ./install.sh --server     # minimal CLI-only profile for headless servers
#   ./install.sh --wsl        # force WSL-aware mode (normally auto-detected)
#   ./install.sh --yes        # accept all prompts (combine with any flag above)
#   ./install.sh --help
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck disable=SC1091
source "$DOTFILES_DIR/scripts/lib.sh"

# --------------------------------------------------------------------
# Arg parsing
# --------------------------------------------------------------------
PROFILE="desktop"
FORCE_WSL=0
YES_ALL=0

usage() {
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --server) PROFILE="server" ;;
        --desktop) PROFILE="desktop" ;;
        --wsl) FORCE_WSL=1 ;;
        --yes|-y) YES_ALL=1 ;;
        -h|--help) usage ;;
        *) err "Unknown flag: $arg"; usage ;;
    esac
done

export PROFILE YES_ALL

# --------------------------------------------------------------------
# OS detection
# --------------------------------------------------------------------
UNAME_S="$(uname -s 2>/dev/null || echo unknown)"
case "$UNAME_S" in
    MINGW*|MSYS*|CYGWIN*)
        err "Windows native (Git Bash / MSYS / Cygwin) is not supported."
        echo
        echo "This installer uses apt, sudo, and Linux paths. To use these dotfiles"
        echo "on Windows, install WSL2 (Ubuntu or Linux Mint) and re-run inside the"
        echo "WSL shell:"
        echo
        echo "    wsl --install -d Ubuntu"
        echo "    # then, inside WSL:"
        echo "    git clone https://github.com/hafidnrzs/dotfiles ~/dotfiles"
        echo "    cd ~/dotfiles && ./install.sh"
        echo
        exit 1
        ;;
    Darwin)
        err "macOS is not supported (no apt, different paths)."
        exit 1
        ;;
    Linux) ;;
    *)
        err "Unrecognised OS: $UNAME_S. This installer expects Linux."
        exit 1
        ;;
esac

# WSL auto-detection (kernel string contains "microsoft" or "WSL")
IS_WSL=0
if [ "$FORCE_WSL" = "1" ] || grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    IS_WSL=1
fi
export IS_WSL

# Warn if repo lives on a Windows-mounted drive under WSL (symlinks are broken there)
if [ "$IS_WSL" = "1" ] && [[ "$DOTFILES_DIR" == /mnt/* ]]; then
    err "Repo is on a Windows-mounted drive: $DOTFILES_DIR"
    echo
    echo "Symlinks created on /mnt/c or /mnt/d do not behave correctly on Linux."
    echo "Please re-clone the repo into your WSL home directory:"
    echo "    cd ~ && git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./install.sh"
    echo
    exit 1
fi

banner() {
    cat <<'EOF'

  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝

EOF
}

banner
echo "  Profile : $PROFILE$([ "$IS_WSL" = "1" ] && echo " (WSL detected)")$([ "$YES_ALL" = "1" ] && echo " [--yes: unattended]")"
echo "  Target  : $DOTFILES_DIR"
echo

# Distro check
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" && "${ID:-}" != "linuxmint" && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    warn "Detected $PRETTY_NAME. Scripts are tuned for Ubuntu/Mint; YMMV."
    ask "Proceed anyway?" n || exit 0
fi

if ! ask "Continue?" y; then
    echo "Aborted."
    exit 0
fi

run_step() {
    local name="$1"; local script="$2"; local default="${3:-y}"
    echo
    if ask "Run: $name" "$default"; then
        bash "$DOTFILES_DIR/scripts/$script"
    else
        warn "Skipped: $name"
    fi
}

# --------------------------------------------------------------------
# Flow
# --------------------------------------------------------------------
if [ "$PROFILE" = "server" ]; then
    run_step "1. Install server baseline CLI (minimal, headless-safe)" 00-server-baseline.sh y
    run_step "2. Apply symlinks (gitconfig + bashrc block only)"       99-symlinks.sh      y

    echo
    ok "Server profile finished."
    echo
    echo "Next steps:"
    echo "  * Edit ~/.gitconfig.local     (your git identity)"
    echo "  * Edit ~/.config/shell.local  (API keys / env vars (chmod 600))"
    exit 0
fi

# Desktop profile (default)
run_step "1. Install baseline CLI packages (git, curl, fish, build tools, ...)" 01-apt-packages.sh y
run_step "2. Install fish shell + fisher + plugins, set as default"             02-shell-fish.sh   y
run_step "3. Install dev runtimes (NVM + Node LTS, Go, uv, PHP, rtk?)"               03-dev-tools.sh    y
run_step "4. Apply symlinks & bashrc managed block"                             99-symlinks.sh     y
run_step "5. Print recommended software list (official links, not auto-installed)" 05-recommendations.sh y

echo
ok "Installer finished."
echo
echo "Next steps:"
echo "  1. Edit ~/.gitconfig.local    (your git identity)"
echo "  2. Edit ~/.config/shell.local (put your API keys / secrets here (chmod 600))"
echo "  3. Pick the apps you want from the recommendation list above."
echo "  4. Once VS Code is installed, run:"
echo "         bash $DOTFILES_DIR/scripts/04-vscode-extensions.sh"
echo "  5. Log out and back in for the default shell (fish) change to take effect."
