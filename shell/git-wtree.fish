# git-wtree go subcommand shell wrapper for fish
# This function enables directory navigation with 'git wtree go'
# Source this file in your config.fish: source /path/to/git-wtree.fish

function git-wtree-go
    set -l target $argv[1]
    
    if test -z "$target"
        echo "Usage: git-wtree-go <worktree-name>" >&2
        return 1
    end
    
    # Call git-wtree go with --print-path to get the directory
    set -l dir (git wtree go --print-path "$target" 2>/dev/null)
    
    if test $status -eq 0; and test -n "$dir"
        cd "$dir"
        or return 1
        echo "Changed to worktree: $dir" >&2
    else
        # If --print-path failed, fall back to normal output
        git wtree go "$target"
        return 1
    end
end

# Optional: Create an alias for convenience
alias wtgo='git-wtree-go'