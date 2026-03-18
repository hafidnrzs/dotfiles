export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Load local machine-specific config (not tracked by git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
