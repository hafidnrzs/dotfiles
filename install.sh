#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Dotfiles Installer ==="
echo ""

# --- Shell selection ---
echo "Which shell do you want to use?"
echo "  1) zsh (installs zsh + oh-my-zsh)"
echo "  2) bash (no extra install)"
read -rp "Choice [1/2]: " shell_choice

USE_ZSH=false
if [[ "$shell_choice" == "1" ]]; then
    USE_ZSH=true
fi

# --- Install zsh + oh-my-zsh ---
if [[ "$USE_ZSH" == true ]]; then
    echo ""
    echo "-> Installing zsh..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y zsh
    elif command -v yum &>/dev/null; then
        sudo yum install -y zsh
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y zsh
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm zsh
    else
        echo "ERROR: Could not detect package manager. Install zsh manually."
        exit 1
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "-> Installing oh-my-zsh..."
        RUNZSH=no CHSH=no sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "-> oh-my-zsh already installed, skipping."
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        echo "-> Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        echo "-> Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
fi

# --- Symlink dotfiles ---
echo ""
echo "-> Linking .gitconfig..."
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    echo "-> Creating ~/.gitconfig.local from example..."
    cp "$DOTFILES_DIR/.gitconfig.local.example" "$HOME/.gitconfig.local"
    echo "   Edit ~/.gitconfig.local to set your name, email, and credential helper."
else
    echo "-> ~/.gitconfig.local already exists, skipping."
fi

if [[ "$USE_ZSH" == true ]]; then
    echo "-> Linking .zshrc..."
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        echo "-> Creating ~/.zshrc.local from example..."
        cp "$DOTFILES_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
        echo "   Edit ~/.zshrc.local to add machine-specific config."
    else
        echo "-> ~/.zshrc.local already exists, skipping."
    fi
fi

# --- Set default shell ---
if [[ "$USE_ZSH" == true ]]; then
    ZSH_PATH="$(command -v zsh)"
    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        echo ""
        echo "-> Setting zsh as default shell..."
        chsh -s "$ZSH_PATH"
        echo "   Log out and back in for the change to take effect."
    else
        echo "-> zsh is already the default shell."
    fi
fi

echo ""
echo "Done."
