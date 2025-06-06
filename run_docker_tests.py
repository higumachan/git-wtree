#!/usr/bin/env python3
"""
Docker Integration Test Runner for git-wtree

This script builds a Docker image and runs integration tests for git-wtree.
It uses only Python standard library modules.
"""

import subprocess
import sys
import os
import tempfile
import shutil
import argparse
from datetime import datetime

class DockerTestRunner:
    def __init__(self, image_name="git-wtree-test", verbose=False):
        self.image_name = image_name
        self.verbose = verbose
        self.container_name = f"{image_name}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
    def log(self, message, level="INFO"):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] [{level}] {message}")
        
    def run_command(self, command, capture_output=True):
        """Run a shell command and return the result."""
        self.log(f"Running command: {' '.join(command)}", "DEBUG" if self.verbose else "INFO")
        
        try:
            if capture_output:
                result = subprocess.run(
                    command,
                    capture_output=True,
                    text=True,
                    check=True
                )
                if self.verbose and result.stdout:
                    print(result.stdout)
                return result
            else:
                # For streaming output
                return subprocess.run(command, check=True)
        except subprocess.CalledProcessError as e:
            self.log(f"Command failed: {e}", "ERROR")
            if e.stdout:
                print("STDOUT:", e.stdout)
            if e.stderr:
                print("STDERR:", e.stderr)
            raise
    
    def build_image(self):
        """Build the Docker image."""
        self.log("Building Docker image...")
        
        build_command = [
            "docker", "build",
            "-t", self.image_name,
            "-f", "Dockerfile",
            "."
        ]
        
        if self.verbose:
            build_command.append("--progress=plain")
            
        self.run_command(build_command, capture_output=not self.verbose)
        self.log(f"Docker image '{self.image_name}' built successfully")
        
    def run_tests(self):
        """Run the integration tests in a Docker container."""
        self.log("Starting test container...")
        
        # Copy test script to container via volume mount
        test_script_path = os.path.abspath("tests/integration_test.fish")
        
        run_command = [
            "docker", "run",
            "--rm",
            "--name", self.container_name,
            "-v", f"{test_script_path}:/home/testuser/integration_test.fish:ro",
            self.image_name,
            "-c", "fish /home/testuser/integration_test.fish"
        ]
        
        try:
            result = self.run_command(run_command, capture_output=False)
            self.log("Tests completed successfully", "SUCCESS")
            return True
        except subprocess.CalledProcessError:
            self.log("Tests failed", "ERROR")
            return False
    
    def cleanup(self):
        """Clean up Docker resources."""
        self.log("Cleaning up...")
        
        # Stop container if running
        try:
            self.run_command([
                "docker", "stop", self.container_name
            ], capture_output=True)
        except subprocess.CalledProcessError:
            # Container might not be running
            pass
        
        # Remove container
        try:
            self.run_command([
                "docker", "rm", "-f", self.container_name
            ], capture_output=True)
        except subprocess.CalledProcessError:
            # Container might not exist
            pass
    
    def list_images(self):
        """List Docker images related to git-wtree."""
        result = self.run_command([
            "docker", "images",
            "--filter", f"reference={self.image_name}*",
            "--format", "table {{.Repository}}\\t{{.Tag}}\\t{{.Size}}\\t{{.CreatedAt}}"
        ])
        print(result.stdout)
    
    def remove_image(self):
        """Remove the Docker image."""
        self.log(f"Removing Docker image '{self.image_name}'...")
        try:
            self.run_command(["docker", "rmi", self.image_name])
            self.log("Image removed successfully")
        except subprocess.CalledProcessError:
            self.log("Failed to remove image", "ERROR")

def main():
    parser = argparse.ArgumentParser(
        description="Run git-wtree integration tests in Docker"
    )
    parser.add_argument(
        "--build-only",
        action="store_true",
        help="Only build the Docker image without running tests"
    )
    parser.add_argument(
        "--no-build",
        action="store_true",
        help="Skip building the Docker image"
    )
    parser.add_argument(
        "--image-name",
        default="git-wtree-test",
        help="Docker image name (default: git-wtree-test)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )
    parser.add_argument(
        "--list-images",
        action="store_true",
        help="List Docker images and exit"
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove Docker image and exit"
    )
    
    args = parser.parse_args()
    
    runner = DockerTestRunner(
        image_name=args.image_name,
        verbose=args.verbose
    )
    
    # Handle special commands
    if args.list_images:
        runner.list_images()
        return 0
    
    if args.clean:
        runner.remove_image()
        return 0
    
    try:
        # Build image if needed
        if not args.no_build:
            runner.build_image()
        
        # Run tests unless build-only
        if not args.build_only:
            success = runner.run_tests()
            return 0 if success else 1
        
        return 0
        
    except KeyboardInterrupt:
        runner.log("Interrupted by user", "WARNING")
        runner.cleanup()
        return 130
    except Exception as e:
        runner.log(f"Unexpected error: {e}", "ERROR")
        runner.cleanup()
        return 1

if __name__ == "__main__":
    sys.exit(main())