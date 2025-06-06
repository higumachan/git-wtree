# Docker Integration Tests for git-wtree

This directory contains Docker-based integration tests for git-wtree.

## Overview

The integration test suite runs git-wtree in an isolated Docker container to verify its functionality in a clean environment. Tests are written in Fish shell script and executed via a Python runner script.

## Files

- `Dockerfile` - Multi-stage Docker image definition for building and running git-wtree
- `tests/integration_test.fish` - Fish script containing the actual test scenarios
- `run_docker_tests.py` - Python script to orchestrate Docker operations and test execution
- `.dockerignore` - Excludes unnecessary files from Docker build context

## Prerequisites

- Docker installed and running
- Python 3.x (standard library only, no additional packages required)

## Usage

### Run all tests
```bash
./run_docker_tests.py
```

### Options

- `--build-only` - Only build the Docker image without running tests
- `--no-build` - Skip building the Docker image (use existing)
- `--verbose` or `-v` - Enable verbose output
- `--image-name NAME` - Use custom Docker image name (default: git-wtree-test)
- `--list-images` - List Docker images and exit
- `--clean` - Remove Docker image and exit

### Examples

```bash
# Build image and run tests with verbose output
./run_docker_tests.py -v

# Only build the Docker image
./run_docker_tests.py --build-only

# Run tests using existing image
./run_docker_tests.py --no-build

# Clean up Docker image
./run_docker_tests.py --clean
```

## Test Scenarios

The integration tests cover the following git-wtree functionality:

1. **Empty worktree list** - Verify `git-wtree list` works with no worktrees
2. **Add worktree** - Test `git-wtree add` creates worktrees correctly
3. **List worktrees** - Verify worktrees appear in `git-wtree list`
4. **Multiple worktrees** - Test handling of multiple worktrees
5. **Navigate to worktree** - Test `git-wtree go` changes directory
6. **Remove worktree** - Test `git-wtree remove` functionality
7. **Prune worktrees** - Test `git-wtree prune` cleans up properly

## Docker Image

The Docker image is built in two stages:

1. **Build stage** - Uses rust:alpine to compile git-wtree
2. **Runtime stage** - Minimal alpine image with git, fish, and the compiled binary

The final image is lightweight and contains only the necessary runtime dependencies.

## Troubleshooting

If tests fail:

1. Run with `--verbose` flag to see detailed output
2. Check Docker daemon is running: `docker info`
3. Ensure you have permissions to run Docker commands
4. Verify the source code builds correctly outside Docker

## Development

To add new test scenarios:

1. Edit `tests/integration_test.fish`
2. Add test functions following the existing pattern
3. Use the provided assertion functions (`assert_success`, `assert_contains`, etc.)
4. Run tests to verify changes