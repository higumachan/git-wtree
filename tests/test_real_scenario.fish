#!/usr/bin/env fish

# Real scenario test for git-wtree completions
# This test creates a temporary git repository and tests completions in a real environment

function test_real_scenario
    echo "=== Testing git-wtree completions in real scenario ==="
    
    # Create temporary test directory
    set -l test_dir (mktemp -d /tmp/git-wtree-test.XXXXXX)
    echo "Test directory: $test_dir"
    
    # Save current directory
    set -l original_dir (pwd)
    
    # Setup test repository
    cd $test_dir
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "# Test Repo" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create branches
    git branch develop
    git branch feature/auth
    git branch feature/ui
    git branch bugfix/login
    
    # Source the completion file
    source $original_dir/../completions/git-wtree.fish
    
    echo
    echo "Testing subcommand completions..."
    set -l subcommands (complete -C"git-wtree " | string split -m1 \t | string trim)
    echo "Available subcommands: $subcommands"
    
    echo
    echo "Testing branch completions for 'add' command..."
    set -l branches (complete -C"git-wtree add " | string split -m1 \t | string trim)
    echo "Available branches: $branches"
    
    # Create a worktree
    git worktree add ../test-develop develop
    
    echo
    echo "Testing worktree completions for 'go' command..."
    set -l worktrees (complete -C"git-wtree go " | string split -m1 \t | string trim)
    echo "Available worktrees: $worktrees"
    
    echo
    echo "Testing alias completions..."
    set -l ls_completions (complete -C"git-wtree l" | string split -m1 \t | string trim)
    echo "Completions for 'l': $ls_completions"
    
    # Cleanup
    cd $original_dir
    rm -rf $test_dir
    
    echo
    echo "=== Real scenario test completed ==="
end

# Run test if executed directly
if test (basename (status -f)) = "test_real_scenario.fish"
    test_real_scenario
end