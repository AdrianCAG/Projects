#!/usr/bin/env python3
"""
Clean and Setup Script for Graph App
This script removes the existing virtual environment and prepares 
the system for a fresh setup with the run_app.py script.
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path

# Colors for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_header(text):
    print(f"{Colors.HEADER}{Colors.BOLD}{text}{Colors.ENDC}")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.ENDC}")

def print_error(text):
    print(f"{Colors.RED}✗ {text}{Colors.ENDC}")

def print_info(text):
    print(f"{Colors.YELLOW}→ {text}{Colors.ENDC}")

def clean_project():
    """Remove existing virtual environment and build files to ensure a clean state"""
    print_header("Cleaning up project environment...")
    
    # Get project directory (where this script is located)
    project_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    venv_dir = project_dir / "venv"
    build_dir = project_dir / "build"
    
    # Clean virtual environment
    if venv_dir.exists():
        print_info(f"Removing virtual environment at: {venv_dir}")
        try:
            shutil.rmtree(venv_dir)
            print_success("Virtual environment removed successfully")
        except Exception as e:
            print_error(f"Failed to remove virtual environment: {e}")
            return False
    else:
        print_info("No virtual environment found to clean up")
    
    # Clean build directory
    if build_dir.exists():
        print_info(f"Removing build directory at: {build_dir}")
        try:
            shutil.rmtree(build_dir)
            print_success("Build directory removed successfully")
        except Exception as e:
            print_error(f"Failed to remove build directory: {e}")
            return False
    else:
        print_info("No build directory found to clean up")
    
    # Check for __pycache__ directories and remove them
    print_info("Cleaning up Python cache files...")
    try:
        for pycache_dir in project_dir.glob("**/__pycache__"):
            if pycache_dir.is_dir():
                shutil.rmtree(pycache_dir)
        print_success("Python cache files cleaned up")
    except Exception as e:
        print_error(f"Error cleaning up cache files: {e}")
    
    return True

def verify_python_setup():
    """Check that Python and pip are properly installed"""
    print_header("Verifying Python setup...")
    
    try:
        # Check Python version
        result = subprocess.run([sys.executable, "--version"], 
                             check=True, capture_output=True, text=True)
        print_success(f"Python available: {result.stdout.strip()}")
        
        # Check pip
        result = subprocess.run([sys.executable, "-m", "pip", "--version"], 
                             check=True, capture_output=True, text=True)
        print_success(f"Pip available: {result.stdout.strip()}")
        
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Python verification failed: {e}")
        return False
    except Exception as e:
        print_error(f"Unexpected error during Python verification: {e}")
        return False

def main():
    print_header("Graph App - Clean and Setup")
    print_info("This script will prepare your system for running the Graph App")
    print_info("It will remove any existing virtual environment and build files to save disk space")
    print_info("The necessary Python environment will be created automatically when you run the app")
    print()
    
    # Clean up existing virtual environment and build directory
    if not clean_project():
        print_error("Failed to clean up the environment")
        return 1
    
    # Verify Python is properly set up
    if not verify_python_setup():
        print_error("Python installation not properly configured")
        print_info("Please ensure Python 3.6+ is installed and available in your PATH")
        return 1
    
    print()
    print_success("System is ready for Graph App")
    print_info("Run './run_app.py' to build and start the application")
    print_info("A fresh Python environment will be created automatically")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
