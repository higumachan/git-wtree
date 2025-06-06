# Fish Shell Completion for git-wtree

This directory contains fish shell completion support for the `git-wtree` command.

## Installation

1. Copy the completion file to your fish completions directory:
   ```bash
   cp completions/git-wtree.fish ~/.config/fish/completions/
   ```

2. Reload your fish shell or start a new session.

## Features

The completion provides:

- **Subcommand completion**: Completes all available subcommands including aliases
  - `add` - Create a new worktree
  - `list` / `ls` - List all worktrees
  - `go` - Show navigation guide to a worktree
  - `remove` / `rm` - Remove a worktree
  - `status` - Show status of all worktrees
  - `clean` - Clean up missing worktrees

- **Context-aware completion**:
  - Branch names after `git-wtree add`
  - Worktree names after `git-wtree go` and `git-wtree remove`
  - Path completion for the optional second argument of `add`

## Testing

The completion includes a comprehensive test suite using fish's built-in testing capabilities.

### Running Tests

1. Basic unit tests:
   ```bash
   cd tests
   fish test_completion.fish
   ```

2. Real scenario test (creates a temporary git repository):
   ```bash
   cd tests
   fish test_real_scenario.fish
   ```

### Test Coverage

The test suite covers:
- Subcommand completion
- Alias support (ls, rm)
- Branch name completion for the `add` command
- Worktree name completion for `go` and `remove` commands
- No completion after terminal commands (status, clean, list)
- Path completion behavior

## Development

### File Structure

```
completions/
  git-wtree.fish    # Main completion file
tests/
  test_completion.fish      # Unit tests
  test_real_scenario.fish   # Integration test
  setup_test_repo.fish      # Helper to create test repository
docs/
  completion.md     # Completion strategy documentation
```

### Helper Functions

The completion uses several helper functions:
- `__fish_git_wtree_using_command` - Check if a specific subcommand is being used
- `__fish_git_wtree_needs_command` - Check if no subcommand is specified yet
- `__fish_git_wtree_branches` - List available git branches
- `__fish_git_wtree_worktrees` - List existing worktrees
- `__fish_git_wtree_add_needs_branch` - Check if add command needs branch completion
- `__fish_git_wtree_add_needs_path` - Check if add command needs path completion