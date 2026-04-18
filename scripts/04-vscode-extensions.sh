#!/usr/bin/env bash
# Install VS Code extensions from config/vscode/extensions.txt.
# Interactive: show the list, let user pick (all / none / a subset).
source "$(dirname "$0")/lib.sh"

if ! have code; then
    warn "VS Code (code) not installed; skipping extensions."
    exit 0
fi

LIST="$DOTFILES_DIR/config/vscode/extensions.txt"
if [ ! -f "$LIST" ]; then
    warn "Extensions list not found at $LIST; skipping."
    exit 0
fi

mapfile -t EXTS < <(grep -vE '^\s*(#|$)' "$LIST")

info "VS Code extensions available in dotfiles:"
for i in "${!EXTS[@]}"; do
    printf "  %3d) %s\n" "$((i+1))" "${EXTS[$i]}"
done

echo
echo "Choose which to install:"
echo "  a = install ALL"
echo "  n = install NONE (skip)"
echo "  <nums> = space-separated numbers to install (e.g. 1 3 5 12)"
read -rp "Choice: " choice

declare -a PICK=()
case "$choice" in
    a|A)
        PICK=("${EXTS[@]}")
        ;;
    n|N|"")
        ok "Skipping VS Code extensions."
        exit 0
        ;;
    *)
        for n in $choice; do
            if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#EXTS[@]}" ]; then
                PICK+=("${EXTS[$((n-1))]}")
            else
                warn "Ignoring invalid selection: $n"
            fi
        done
        ;;
esac

for ext in "${PICK[@]}"; do
    info " -> $ext"
    code --install-extension "$ext" --force || warn "Failed: $ext"
done

ok "VS Code extensions step done."
