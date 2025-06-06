#!/usr/bin/env fish

# Integration test for git-wtree
# This test verifies core functionality of git-wtree

set -g TEST_FAILED 0
set -g TEST_COUNT 0
set -g PASSED_COUNT 0

function assert_success
    set -l description $argv[1]
    set -l last_status $status
    set -g TEST_COUNT (math $TEST_COUNT + 1)
    
    if test $last_status -eq 0
        set -g PASSED_COUNT (math $PASSED_COUNT + 1)
        echo "✓ $description"
    else
        set -g TEST_FAILED 1
        echo "✗ $description (exit code: $last_status)"
    end
end

function assert_contains
    set -l haystack $argv[1]
    set -l needle $argv[2]
    set -l description $argv[3]
    set -g TEST_COUNT (math $TEST_COUNT + 1)
    
    if string match -q "*$needle*" $haystack
        set -g PASSED_COUNT (math $PASSED_COUNT + 1)
        echo "✓ $description"
    else
        set -g TEST_FAILED 1
        echo "✗ $description (expected to contain: $needle)"
    end
end

function assert_not_contains
    set -l haystack $argv[1]
    set -l needle $argv[2]
    set -l description $argv[3]
    set -g TEST_COUNT (math $TEST_COUNT + 1)
    
    if not string match -q "*$needle*" $haystack
        set -g PASSED_COUNT (math $PASSED_COUNT + 1)
        echo "✓ $description"
    else
        set -g TEST_FAILED 1
        echo "✗ $description (expected not to contain: $needle)"
    end
end

function run_integration_tests
    echo "=== Starting git-wtree integration tests ==="
    echo
    
    # Create test directory
    set -l test_dir (mktemp -d /tmp/git-wtree-test.XXXXXX)
    cd $test_dir
    
    # Initialize git repository
    echo "Setting up test repository..."
    git init --quiet
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit" --quiet
    
    # Create test branches
    git branch develop --quiet
    git branch feature/test-1 --quiet
    git branch feature/test-2 --quiet
    git branch bugfix/test-fix --quiet
    
    echo
    echo "Running tests..."
    echo
    
    # Test 1: git-wtree list (empty)
    echo "Test: git-wtree list (empty worktree list)"
    set -l list_output (git-wtree list 2>&1)
    assert_success "git-wtree list should succeed with empty list"
    
    # Test 2: git-wtree add
    echo
    echo "Test: git-wtree add"
    git-wtree add develop ../develop-worktree
    assert_success "git-wtree add should create worktree"
    
    # Verify worktree was created
    test -d ../develop-worktree
    assert_success "Worktree directory should exist"
    
    # Test 3: git-wtree list (with worktree)
    echo
    echo "Test: git-wtree list (with worktree)"
    set -l list_output (git-wtree list)
    assert_success "git-wtree list should succeed"
    assert_contains "$list_output" "develop" "List should contain develop worktree"
    
    # Test 4: git-wtree add another worktree
    echo
    echo "Test: git-wtree add another worktree"
    git-wtree add feature/test-1
    assert_success "git-wtree add without path should succeed"
    
    # Test 5: git-wtree list multiple worktrees
    echo
    echo "Test: git-wtree list (multiple worktrees)"
    set -l list_output (git-wtree list)
    assert_success "git-wtree list should succeed with multiple worktrees"
    assert_contains "$list_output" "develop" "List should contain develop"
    assert_contains "$list_output" "feature/test-1" "List should contain feature/test-1"
    
    # Test 6: git-wtree go
    echo
    echo "Test: git-wtree go"
    set -l original_dir (pwd)
    cd (git-wtree go develop 2>&1 | tail -1)
    set -l current_dir (pwd)
    assert_contains "$current_dir" "develop-worktree" "Should change to develop worktree"
    cd $original_dir
    
    # Test 7: git-wtree remove
    echo
    echo "Test: git-wtree remove"
    git-wtree remove develop
    assert_success "git-wtree remove should succeed"
    
    # Verify worktree was removed from list
    set -l list_output (git-wtree list)
    assert_not_contains "$list_output" "develop" "List should not contain removed worktree"
    
    # Test 8: git-wtree prune
    echo
    echo "Test: git-wtree prune"
    # Manually remove a worktree directory to test prune
    rm -rf ../feature-test-1
    git-wtree prune
    assert_success "git-wtree prune should succeed"
    
    # Cleanup
    cd /tmp
    rm -rf $test_dir
    
    # Summary
    echo
    echo "=== Test Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASSED_COUNT"
    echo "Failed: "(math $TEST_COUNT - $PASSED_COUNT)
    
    if test $TEST_FAILED -eq 0
        echo
        echo "All tests passed! ✓"
        return 0
    else
        echo
        echo "Some tests failed! ✗"
        return 1
    end
end

# Run tests if executed directly
if test (basename (status -f)) = "integration_test.fish"
    run_integration_tests
    exit $status
end