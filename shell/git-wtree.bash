#!/bin/bash

# git-wtree go subcommand shell wrapper for bash
# This function enables directory navigation with 'git wtree go'
# Source this file in your .bashrc: source /path/to/git-wtree.bash

git-wtree-go() {
    local target="$1"
    
    if [ -z "$target" ]; then
        echo "Usage: git-wtree-go <worktree-name>" >&2
        return 1
    fi
    
    # Call git-wtree go with --print-path to get the directory
    local dir
    dir=$(git wtree go --print-path "$target" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$dir" ]; then
        cd "$dir" || return 1
        echo "Changed to worktree: $dir" >&2
    else
        # If --print-path failed, fall back to normal output
        git wtree go "$target"
        return 1
    fi
}

# Optional: Create an alias for convenience
alias wtgo='git-wtree-go'