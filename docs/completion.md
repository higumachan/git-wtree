# Fish Completion Strategy for git-wtree

## Overview
This document outlines the strategy for implementing fish shell completion for the git-wtree command.

## Command Structure
The git-wtree command has the following subcommands:
- `add <branch> [path]` - Create a new worktree
- `list` (alias: `ls`) - List all worktrees
- `go <name>` - Show navigation guide to a worktree
- `remove <name>` (alias: `rm`) - Remove a worktree
- `status` - Show status of all worktrees
- `clean` - Clean up missing worktrees

## Completion Requirements

### 1. Subcommand Completion
- Complete all available subcommands when user types `git-wtree <TAB>`
- Include aliases (ls for list, rm for remove)

### 2. Branch Completion for `add`
- Complete existing git branch names when typing `git-wtree add <TAB>`
- Support both local branches and remotes

### 3. Worktree Name Completion for `go` and `remove`
- Complete existing worktree names when typing `git-wtree go <TAB>` or `git-wtree remove <TAB>`
- Include both worktree identifiers and branch names

### 4. Path Completion for `add`
- Standard file path completion for the optional path argument

## Implementation Approach

### 1. Helper Functions
- `__git_wtree_list_branches` - List all git branches
- `__git_wtree_list_worktrees` - List all existing worktrees
- `__git_wtree_using_command` - Check which subcommand is being used

### 2. Main Completion Function
- `__fish_complete_git_wtree` - Main completion dispatcher

### 3. Test-Driven Development
- Write tests for each completion scenario
- Use fish's built-in test framework
- Test edge cases and error conditions

## Test Cases
1. Subcommand completion
2. Branch name completion for add command
3. Worktree name completion for go/remove commands
4. Path completion for add command
5. No completion after status/clean/list commands
6. Proper handling of aliases

## File Structure
- `completions/git-wtree.fish` - Main completion file
- `tests/completion_test.fish` - Test file for completions