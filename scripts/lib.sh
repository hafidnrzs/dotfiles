#!/usr/bin/env bash
# Shared helpers for install scripts. Source this from each module.

set -euo pipefail

# Colors
if [ -t 1 ]; then
    C_RESET="$(printf '\033[0m')"
    C_BOLD="$(printf '\033[1m')"
    C_BLUE="$(printf '\033[34m')"
    C_GREEN="$(printf '\033[32m')"
    C_YELLOW="$(printf '\033[33m')"
    C_RED="$(printf '\033[31m')"
else
    C_RESET=""; C_BOLD=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""
fi

info()  { printf "%s==>%s %s\n" "$C_BLUE$C_BOLD" "$C_RESET" "$*"; }
ok()    { printf "%s[ok]%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "%s[warn]%s %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()   { printf "%s[err]%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; }

# ask "Question" <default yn>
# Returns 0 for yes, 1 for no. Default used when input is empty.
# When YES_ALL=1 (set by --yes flag), skips the prompt and returns the default.
ask() {
    local prompt="$1"; local default="${2:-n}"
    local hint="[y/N]"; [ "$default" = "y" ] && hint="[Y/n]"
    if [ "${YES_ALL:-0}" = "1" ]; then
        printf "%s %s %s\n" "$prompt" "$hint" "(auto: ${default})"
        [ "$default" = "y" ] && return 0 || return 1
    fi
    local reply
    read -rp "$prompt $hint " reply
    reply="${reply:-$default}"
    case "$reply" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

have() { command -v "$1" >/dev/null 2>&1; }

apt_install() {
    sudo apt-get install -y --no-install-recommends "$@"
}

ensure_apt_updated() {
    if [ "${APT_UPDATED:-0}" != "1" ]; then
        info "Running apt update..."
        sudo apt-get update -qq
        export APT_UPDATED=1
    fi
}

# DOTFILES_DIR is normally set by install.sh. When a script is run standalone,
# auto-detect from this file's location (scripts/ is a direct child of the repo).
if [ -z "${DOTFILES_DIR:-}" ]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    export DOTFILES_DIR
fi

SHELL_LOCAL="$HOME/.config/shell.local"
append_local() {
    local marker="# --- $1 ---"
    local content="$2"
    # Ensure directory exists before checking/appending
    mkdir -p "$(dirname "$SHELL_LOCAL")"
    if [ ! -f "$SHELL_LOCAL" ]; then
        touch "$SHELL_LOCAL"
        chmod 600 "$SHELL_LOCAL"
    fi
    if ! grep -qF "$marker" "$SHELL_LOCAL"; then
        info "Appending $1 config to $SHELL_LOCAL..."
        {
            echo ""
            echo "$marker"
            echo "$content"
        } >> "$SHELL_LOCAL"
    fi
}
