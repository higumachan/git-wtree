#!/bin/bash
# Bash completion for git-wtree

# Helper function to list git branches
_git_wtree_branches() {
    # List local branches
    git branch --format='%(refname:short)' 2>/dev/null
    # List remote branches (optional, removing origin/ prefix)
    git branch -r --format='%(refname:short)' 2>/dev/null | sed 's|^origin/||'
}

# Helper function to list worktrees
_git_wtree_worktrees() {
    # First, add "main" for the main worktree
    echo "main"
    
    # Then list other worktrees by parsing git worktree list output
    git worktree list --porcelain 2>/dev/null | grep '^worktree ' | sed 's/^worktree //' | while read -r path; do
        # Extract the last component of the path as the worktree name
        basename "$path"
    done
}

# Main completion function
_git_wtree() {
    local cur prev words cword
    _init_completion || return

    local subcommands="add list ls go goroot remove rm status clean"
    
    # If we're on the first argument (subcommand)
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$subcommands" -- "$cur") )
        return
    fi
    
    # Get the subcommand
    local subcmd="${words[1]}"
    
    case "$subcmd" in
        add)
            if [[ $cword -eq 2 ]]; then
                # Complete branch names for the first argument
                COMPREPLY=( $(compgen -W "$(_git_wtree_branches)" -- "$cur") )
            elif [[ $cword -eq 3 ]]; then
                # Complete file paths for the second argument
                _filedir -d
            fi
            ;;
        go)
            if [[ $cword -eq 2 ]]; then
                # Complete worktree names
                COMPREPLY=( $(compgen -W "$(_git_wtree_worktrees)" -- "$cur") )
            elif [[ $cword -eq 3 ]] && [[ "$prev" == "--print-path" ]]; then
                # Complete worktree names after --print-path
                COMPREPLY=( $(compgen -W "$(_git_wtree_worktrees)" -- "$cur") )
            elif [[ $cword -eq 3 ]]; then
                # Complete --print-path option if not already present
                COMPREPLY=( $(compgen -W "--print-path" -- "$cur") )
            fi
            ;;
        remove|rm)
            if [[ $cword -eq 2 ]]; then
                # Complete worktree names
                COMPREPLY=( $(compgen -W "$(_git_wtree_worktrees)" -- "$cur") )
            fi
            ;;
        goroot)
            if [[ $cword -eq 2 ]]; then
                # Complete --print-path option
                COMPREPLY=( $(compgen -W "--print-path" -- "$cur") )
            fi
            ;;
        *)
            # No completion for other subcommands
            ;;
    esac
}

# Register the completion for git-wtree
complete -F _git_wtree git-wtree

# Also register for 'git wtree' (when used as a git subcommand)
_git_wtree_git() {
    # Skip 'git' and pass to _git_wtree
    local words=("git-wtree" "${COMP_WORDS[@]:2}")
    local cword=$((COMP_CWORD - 1))
    COMP_WORDS=("${words[@]}")
    COMP_CWORD=$cword
    _git_wtree
}

# Check if git completion is loaded and register our handler
if declare -F __git_complete >/dev/null 2>&1; then
    __git_complete git-wtree _git_wtree_git
fi