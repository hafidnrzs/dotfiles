if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Load machine-specific secrets and env (not tracked by git)
if test -f ~/.config/shell.local
    # shell.local is POSIX sh; source via `bass` if loaded, else parse exports manually
    if type -q bass
        bass source ~/.config/shell.local
    else
        for line in (grep -E '^export [A-Z_]+=' ~/.config/shell.local)
            set -l kv (string replace -r '^export ' '' -- $line)
            set -l k (string split -m1 '=' -- $kv)[1]
            set -l v (string split -m1 '=' -- $kv)[2]
            set -gx $k (string trim -c '"\'' -- $v)
        end
    end
end

# Go
if test -d /usr/local/go/bin
    set -gx PATH /usr/local/go/bin $PATH
end

# Local bin
if test -d ~/.local/bin
    set -gx PATH ~/.local/bin $PATH
end

# NVM
set -gx NVM_DIR ~/.nvm
if type -q bass
    bass source $NVM_DIR/nvm.sh
end

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
