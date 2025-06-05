#!/usr/bin/env fish

# Setup script to create a test git repository with branches and worktrees

function setup_test_repo
    set -l test_dir /tmp/git-wtree-test-repo
    
    # Clean up if exists
    if test -d $test_dir
        rm -rf $test_dir
    end
    
    # Create test repository
    mkdir -p $test_dir
    cd $test_dir
    
    # Initialize git repo
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "# Test Repo" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Create some branches
    git branch develop
    git branch feature/auth
    git branch feature/ui
    git branch bugfix/login
    
    # Create some worktrees
    git worktree add ../test-develop develop
    git worktree add ../test-feature-auth feature/auth
    
    echo "Test repository created at: $test_dir"
    echo "Branches: main, develop, feature/auth, feature/ui, bugfix/login"
    echo "Worktrees: test-develop, test-feature-auth"
end

# Run setup if executed directly
if test (basename (status -f)) = "setup_test_repo.fish"
    setup_test_repo
end