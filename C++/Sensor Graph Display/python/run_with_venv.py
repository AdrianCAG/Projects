#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
This script is a fast wrapper that runs chart_generator.py inside the virtual environment.
It's optimized for performance to reduce the chart generation time.
This version will install required dependencies on-demand if needed.
"""

import os
import sys
import subprocess
import pathlib
import time

# Cache for the virtual environment path
_VENV_PYTHON_PATH = None

def find_venv():
    """Find the virtual environment path with caching for better performance."""
    global _VENV_PYTHON_PATH
    
    # Return cached path if already found
    if _VENV_PYTHON_PATH and os.path.exists(_VENV_PYTHON_PATH):
        return _VENV_PYTHON_PATH
    
    # Get the absolute path of this script
    script_dir = pathlib.Path(__file__).parent.absolute()
    
    # Start with app root directory (parent of python directory)
    app_dir = script_dir.parent
    venv_dir = app_dir / "venv"
    
    # Check if we're in macOS bundle structure
    if "Contents/Resources/python" in str(script_dir) or ".app/" in str(script_dir):
        # Find the .app directory by navigating upwards
        temp_dir = script_dir
        for _ in range(6):  # Limit the levels to avoid infinite loop
            if ".app" in str(temp_dir) and temp_dir.parent.exists():
                # Go one level above the .app bundle
                app_dir = temp_dir.parent.parent
                venv_dir = app_dir / "venv"
                break
            temp_dir = temp_dir.parent
    
    # If venv exists, use it
    if venv_dir.exists():
        # Get the Python executable path based on platform
        if sys.platform == "win32":
            python_path = venv_dir / "Scripts" / "python.exe"
        else:
            python_path = venv_dir / "bin" / "python"
            
        if python_path.exists():
            _VENV_PYTHON_PATH = str(python_path)
            print(f"Found Python in virtual environment: {_VENV_PYTHON_PATH}", file=sys.stderr)
            return _VENV_PYTHON_PATH
    
    print("No virtual environment found, will try to use system Python", file=sys.stderr)
    return None

def main():
    start_time = time.time()
    
    if len(sys.argv) < 2:
        print("Usage: python run_with_venv.py chart_generator.py [args...]")
        sys.exit(1)
    
    # Find the virtual environment Python - optimized with caching
    venv_python = find_venv()
    if not venv_python:
        # If venv not found, fall back to system Python as a last resort
        venv_python = sys.executable
        print(f"Warning: Virtual environment not found, using system Python: {venv_python}")
    
    # Get the chart generator script and arguments
    chart_script = pathlib.Path(__file__).parent / "chart_generator.py"
    if not chart_script.exists():
        print(f"Error: Chart generator script not found at {chart_script}")
        sys.exit(1)
    
    # Pass through all arguments
    args = [str(chart_script)] + sys.argv[2:]
    
    # Handle preload mode specially
    if "--preload" in args:
        print("Python chart backend ready")
        time.sleep(3600)  # Keep alive for an hour
        sys.exit(0)
    
    # Before running the subprocess, make sure required packages are installed
    requirements_file = pathlib.Path(__file__).parent / "requirements.txt"
    if requirements_file.exists():
        print(f"Installing dependencies from {requirements_file}...", file=sys.stderr)
        # Install requirements to current Python if venv not found
        python_to_use = venv_python if venv_python != sys.executable else sys.executable
        
        try:
            result = subprocess.run(
                [python_to_use, "-m", "pip", "install", "-r", str(requirements_file)],
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True,
                check=False  # Don't raise error if installation fails
            )
            if result.returncode == 0:
                print(f"Dependencies installed successfully", file=sys.stderr)
            else:
                print(f"Warning: Failed to install dependencies: {result.stderr}", file=sys.stderr)
                # Fallback to direct package install
                subprocess.run(
                    [python_to_use, "-m", "pip", "install", "matplotlib", "numpy"],
                    stdout=subprocess.PIPE, 
                    stderr=subprocess.PIPE
                )
        except Exception as e:
            print(f"Error during package installation: {e}", file=sys.stderr)
    
    # Run the chart generator with optimized startup options
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"  # Avoid writing .pyc files
    env["PYTHONUNBUFFERED"] = "1"       # Disable buffering for faster I/O
    
    result = subprocess.run(
        [venv_python, "-O"] + args,
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE, 
        text=True,
        env=env,
        # Reduce subprocess creation overhead
        close_fds=False
    )
    
    # Print output and errors
    print(result.stdout, end='')
    if result.stderr:
        print(result.stderr, file=sys.stderr, end='')
    
    end_time = time.time()
    # Return the same exit code
    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
