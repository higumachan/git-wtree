> **Note**: This repository is built with 100% vibe coding. While I use it personally, it's not intended for widespread use. It's public simply because it's easier to share with my acquaintances. I'll respond to issues only when I feel like it, so please use with caution.

# git-wtree

A convenient git worktree wrapper that makes managing multiple worktrees easier and more intuitive.

## 🚀 Features

`git-wtree` provides the following features to enhance your git worktree experience:

### 1. **Create worktree (`add`)**
```bash
git wtree add feature/new-feature
git wtree add hotfix/bug-123 ../hotfix-123
```
- Automatically generates directory names from branch names
- Creates new branches if they don't exist
- Supports custom path specification

### 2. **List worktrees (`list`, `ls`)**
```bash
git wtree list
git wtree ls
```
- Color-coded display for main and worktrees
- Shows HEAD commit and branch name for each worktree
- Clean, organized formatting

### 3. **Navigate to worktree (`go`)**
```bash
git wtree go new-feature
```
- Search by worktree name or branch name
- Displays cd command for navigation
- Shows available worktrees if target not found

### 4. **Remove worktree (`remove`, `rm`)**
```bash
git wtree remove old-feature
git wtree rm old-feature
```
- Identify targets by name or branch
- Safely removes worktrees

### 5. **Check status (`status`)**
```bash
git wtree status
```
- Lists status of all worktrees
- Shows count of uncommitted changes
- Detects missing directories

### 6. **Clean up (`clean`)**
```bash
git wtree clean
```
- Removes worktrees with deleted directories
- Runs `git worktree prune`

## 🎨 Features

### Color Display
- 🟢 Main worktree
- 🔵 Regular worktree
- 🟡 Warning (uncommitted changes)
- 🔴 Error (missing directory)

### Environment Variable Support
```bash
export GIT_WTREE_BASE="~/projects/worktrees"
```
Set default worktree creation location

### Automatic Branch Name Formatting
Converts branch names like `feature/user-auth` to appropriate directory names like `../user-auth`

### Error Handling
- Detects execution outside git repositories
- Prevents access to non-existent worktrees
- Clear error messages

## 💡 Use Cases

1. **Feature Development**: Develop new features in separate directories without leaving main branch
2. **Hotfixes**: Handle urgent fixes in separate worktrees without interrupting current work
3. **Code Review**: Check out others' branches in separate worktrees
4. **Parallel Work**: Develop multiple features simultaneously in different directories

## 📦 Installation

```bash
cargo install git-wtree
```

## 🔧 Configuration

Set the default worktree base directory:
```bash
export GIT_WTREE_BASE=".worktree"  # default
```

## 📝 Usage

```bash
# Create a new worktree
git wtree add feature/awesome-feature

# List all worktrees
git wtree ls

# Navigate to a worktree
git wtree go awesome-feature

# Check status of all worktrees
git wtree status

# Remove a worktree
git wtree rm old-feature

# Clean up missing worktrees
git wtree clean
```

This plugin enables efficient management of multiple work streams without constant branch switching!