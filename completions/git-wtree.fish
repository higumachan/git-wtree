# Fish completion for git-wtree

# Helper function to check if we're using a specific subcommand
function __fish_git_wtree_using_command
    set -l cmd (commandline -opc)
    set -l subcmd $argv[1]
    
    # Check if git-wtree is the command
    if test (count $cmd) -lt 2
        return 1
    end
    
    if test $cmd[1] != "git-wtree"
        return 1
    end
    
    # Check if the subcommand matches
    if test $cmd[2] = $subcmd
        return 0
    else
        return 1
    end
end

# Helper function to check if no subcommand is specified yet
function __fish_git_wtree_needs_command
    set -l cmd (commandline -opc)
    
    if test (count $cmd) -eq 1
        if test $cmd[1] = "git-wtree"
            return 0
        end
    end
    
    return 1
end

# Helper function to list git branches
function __fish_git_wtree_branches
    # List local branches
    git branch --format='%(refname:short)' 2>/dev/null
    # List remote branches (optional, removing origin/ prefix)
    git branch -r --format='%(refname:short)' 2>/dev/null | string replace -r '^origin/' ''
end

# Helper function to list worktrees
function __fish_git_wtree_worktrees
    # First, add "main" for the main worktree
    echo "main"
    
    # Then list other worktrees
    # We need to parse git worktree list output
    git worktree list --porcelain 2>/dev/null | string match -r '^worktree (.+)' | string replace -r '^worktree (.+)' '$1' | while read -l path
        # Extract the last component of the path as the worktree name
        basename $path
    end
end

# Disable file completion for git-wtree
complete -c git-wtree -f

# Subcommands
complete -c git-wtree -n __fish_git_wtree_needs_command -a add -d "Create a new worktree"
complete -c git-wtree -n __fish_git_wtree_needs_command -a list -d "List all worktrees"
complete -c git-wtree -n __fish_git_wtree_needs_command -a ls -d "List all worktrees (alias)"
complete -c git-wtree -n __fish_git_wtree_needs_command -a go -d "Show navigation guide to a worktree"
complete -c git-wtree -n __fish_git_wtree_needs_command -a goroot -d "Navigate to git repository root"
complete -c git-wtree -n __fish_git_wtree_needs_command -a remove -d "Remove a worktree"
complete -c git-wtree -n __fish_git_wtree_needs_command -a rm -d "Remove a worktree (alias)"
complete -c git-wtree -n __fish_git_wtree_needs_command -a status -d "Show status of all worktrees"
complete -c git-wtree -n __fish_git_wtree_needs_command -a clean -d "Clean up missing worktrees"

# Helper function to check argument count for add command
function __fish_git_wtree_add_needs_branch
    set -l cmd (commandline -opc)
    if test (count $cmd) -eq 2; and test $cmd[2] = "add"
        return 0
    end
    return 1
end

function __fish_git_wtree_add_needs_path
    set -l cmd (commandline -opc)
    if test (count $cmd) -eq 3; and test $cmd[2] = "add"
        return 0
    end
    return 1
end

# Completions for 'add' subcommand
# First argument: branch name
complete -c git-wtree -n __fish_git_wtree_add_needs_branch -a "(__fish_git_wtree_branches)" -d "Branch name"

# Second argument: path (re-enable file completion for path)
complete -c git-wtree -n __fish_git_wtree_add_needs_path -F -d "Worktree path"

# Completions for 'go' subcommand
complete -c git-wtree -n "__fish_git_wtree_using_command go" -a "(__fish_git_wtree_worktrees)" -d "Worktree name"
complete -c git-wtree -n "__fish_git_wtree_using_command go" -l print-path -d "Print only the worktree path"

# Completions for 'goroot' subcommand
complete -c git-wtree -n "__fish_git_wtree_using_command goroot" -l print-path -d "Print only the root path"

# Completions for 'remove' and 'rm' subcommands
complete -c git-wtree -n "__fish_git_wtree_using_command remove" -a "(__fish_git_wtree_worktrees)" -d "Worktree name"
complete -c git-wtree -n "__fish_git_wtree_using_command rm" -a "(__fish_git_wtree_worktrees)" -d "Worktree name"