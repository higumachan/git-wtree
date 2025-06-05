#!/usr/bin/env fish

# Test framework setup
set -g test_count 0
set -g test_passed 0
set -g test_failed 0

function describe
    echo
    echo "=== $argv ==="
end

function test_completion
    set -l description $argv[1]
    set -l input $argv[2]
    set -l expected $argv[3..-1]
    
    set test_count (math $test_count + 1)
    
    # Mock the completion by sourcing the completion file and calling complete -C
    set -l actual_raw (complete -C"$input" 2>/dev/null)
    
    # Extract just the completion part (before tab/description)
    set -l actual
    for item in $actual_raw
        # Split by tab and take the first part
        set -l completion (string split -m1 \t -- $item)[1]
        set actual $actual $completion
    end
    
    # Check if actual matches expected
    set -l success 1
    for exp in $expected
        if not contains -- $exp $actual
            set success 0
            break
        end
    end
    
    # Also check if we don't have extra completions
    if test (count $actual) -ne (count $expected)
        set success 0
    end
    
    if test $success -eq 1
        set test_passed (math $test_passed + 1)
        echo "✓ $description"
    else
        set test_failed (math $test_failed + 1)
        echo "✗ $description"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
    end
end

function test_completion_contains
    set -l description $argv[1]
    set -l input $argv[2]
    set -l expected $argv[3..-1]
    
    set test_count (math $test_count + 1)
    
    # Mock the completion by sourcing the completion file and calling complete -C
    set -l actual_raw (complete -C"$input" 2>/dev/null)
    
    # Extract just the completion part (before tab/description)
    set -l actual
    for item in $actual_raw
        # Split by tab and take the first part
        set -l completion (string split -m1 \t -- $item)[1]
        set actual $actual $completion
    end
    
    # Check if actual contains all expected items
    set -l success 1
    for exp in $expected
        if not contains -- $exp $actual
            set success 0
            echo "  Missing: $exp"
        end
    end
    
    if test $success -eq 1
        set test_passed (math $test_passed + 1)
        echo "✓ $description"
    else
        set test_failed (math $test_failed + 1)
        echo "✗ $description"
        echo "  Expected to contain: $expected"
        echo "  Actual: $actual"
    end
end

function run_tests
    # Source the completion file
    source ../completions/git-wtree.fish
    
    describe "Subcommand completion tests"
    
    test_completion_contains \
        "Should complete subcommands" \
        "git-wtree " \
        "add" "list" "go" "remove" "status" "clean"
    
    test_completion_contains \
        "Should include alias 'ls' for list" \
        "git-wtree " \
        "ls"
    
    test_completion_contains \
        "Should include alias 'rm' for remove" \
        "git-wtree " \
        "rm"
    
    test_completion_contains \
        "Should complete 'a' to 'add'" \
        "git-wtree a" \
        "add"
    
    test_completion_contains \
        "Should complete 'l' to 'list' and 'ls'" \
        "git-wtree l" \
        "list" "ls"
    
    test_completion_contains \
        "Should complete 's' to 'status'" \
        "git-wtree s" \
        "status"
    
    describe "Branch completion tests for 'add' command"
    
    # Note: These tests require being in a git repository
    # They will show actual branches if run in a real repo
    function test_has_completions
        set -l description $argv[1]
        set -l input $argv[2]
        
        set test_count (math $test_count + 1)
        
        # Get completions
        set -l actual_raw (complete -C"$input" 2>/dev/null)
        
        if test (count $actual_raw) -gt 0
            set test_passed (math $test_passed + 1)
            echo "✓ $description"
        else
            set test_failed (math $test_failed + 1)
            echo "✗ $description"
            echo "  Expected some completions but got none"
        end
    end
    
    test_has_completions \
        "Should provide branch completions after 'add'" \
        "git-wtree add "
    
    describe "Worktree completion tests for 'go' and 'remove' commands"
    
    test_completion_contains \
        "Should at least complete 'main' after 'go'" \
        "git-wtree go " \
        "main"
    
    test_completion_contains \
        "Should at least complete 'main' after 'remove'" \
        "git-wtree remove " \
        "main"
    
    test_completion_contains \
        "Should at least complete 'main' after 'rm' (alias)" \
        "git-wtree rm " \
        "main"
    
    describe "No completion after terminal commands"
    
    function test_no_completion
        set -l description $argv[1]
        set -l input $argv[2]
        
        set test_count (math $test_count + 1)
        
        # Get completions
        set -l actual_raw (complete -C"$input" 2>/dev/null)
        
        # Extract just the completion part (before tab/description)
        set -l actual
        for item in $actual_raw
            # Split by tab and take the first part
            set -l completion (string split -m1 \t -- $item)[1]
            # Only include if it doesn't start with - (options)
            if not string match -q -- '-*' $completion
                set actual $actual $completion
            end
        end
        
        if test (count $actual) -eq 0
            set test_passed (math $test_passed + 1)
            echo "✓ $description"
        else
            set test_failed (math $test_failed + 1)
            echo "✗ $description"
            echo "  Expected no completions"
            echo "  Actual: $actual"
        end
    end
    
    test_no_completion \
        "Should not complete after 'status'" \
        "git-wtree status "
    
    test_no_completion \
        "Should not complete after 'clean'" \
        "git-wtree clean "
    
    test_no_completion \
        "Should not complete after 'list'" \
        "git-wtree list "
    
    test_no_completion \
        "Should not complete after 'ls' (alias)" \
        "git-wtree ls "
    
    describe "Path completion tests"
    
    # Test that file completion is available for add command's second argument
    # Note: We can't easily test actual file completions in unit tests,
    # but we can verify the completion is set up correctly by checking
    # that branch completions are NOT offered after a branch is specified
    function test_not_branch_completion_after_branch
        set -l description $argv[1]
        set -l input $argv[2]
        
        set test_count (math $test_count + 1)
        
        # Get completions
        set -l actual_raw (complete -C"$input" 2>/dev/null)
        
        # Extract just the completion part
        set -l actual
        for item in $actual_raw
            set -l completion (string split -m1 \t -- $item)[1]
            set actual $actual $completion
        end
        
        # Check that we don't get branch completions
        set -l has_branch_completion 0
        for item in $actual
            # Check if this looks like a branch (contains common branch names)
            if string match -q -e "main" $item; or string match -q -e "develop" $item; or string match -q -e "feature" $item
                set has_branch_completion 1
                break
            end
        end
        
        if test $has_branch_completion -eq 0
            set test_passed (math $test_passed + 1)
            echo "✓ $description"
        else
            set test_failed (math $test_failed + 1)
            echo "✗ $description"
            echo "  Should not show branch completions after branch is specified"
            echo "  Actual: $actual"
        end
    end
    
    test_not_branch_completion_after_branch \
        "Should not show branch completions after branch is specified" \
        "git-wtree add main "
    
    # Print summary
    echo
    echo "============================="
    echo "Test Summary:"
    echo "Total: $test_count"
    echo "Passed: $test_passed"
    echo "Failed: $test_failed"
    echo "============================="
    
    if test $test_failed -gt 0
        return 1
    else
        return 0
    end
end

# Run tests if executed directly
if test (basename (status -f)) = "test_completion.fish"
    run_tests
end