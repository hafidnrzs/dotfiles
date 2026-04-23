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

# List the directories and sort them by the filename timestamp
function lsort
    set -l count 5
    if test (count $argv) -gt 1
        set count $argv[2]
    end
    ls -l $argv[1] | tail -n +2 | sort -k9 -r | head -n $count
end
