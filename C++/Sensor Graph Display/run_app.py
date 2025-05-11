#!/usr/bin/env python3
"""
Sensor Graph Display Launcher
This script helps to build and run the Sensor Graph Display application
This version creates a fresh Python environment on first run.
"""

import os
import sys
import subprocess
import platform
import shutil
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

def check_dependencies():
    print_header("Checking dependencies...")
    
    # Check for Python
    python_version = platform.python_version()
    print_success(f"Python found: {python_version}")
    
    # Check for Qt (CMake will do this for us)
    cmake_path = shutil.which("cmake")
    if cmake_path:
        print_success(f"CMake found: {cmake_path}")
    else:
        print_error("CMake not found. Please install CMake.")
        return False
    
    # Check for pip
    try:
        subprocess.run([sys.executable, "-m", "pip", "--version"], 
                      check=True, capture_output=True, text=True)
        print_success("pip found")
    except:
        print_error("pip not found. Please install pip.")
        return False
    
    return True

def setup_virtual_environment():
    print_header("Setting up Python virtual environment...")
    
    # Get project directory (where this script is located)
    project_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    
    # Always create environment in project directory
    venv_dir = project_dir / "venv"
    
    # If venv exists, remove it to create a fresh one
    if venv_dir.exists():
        print_info(f"Removing existing virtual environment at: {venv_dir}")
        try:
            shutil.rmtree(venv_dir)
            print_success("Existing virtual environment removed successfully")
        except Exception as e:
            print_error(f"Failed to remove existing virtual environment: {e}")
            return None
    
    # Create a fresh virtual environment
    print_info(f"Creating new virtual environment at: {venv_dir}")
    try:
        # Ensure the directory exists
        venv_dir.parent.mkdir(parents=True, exist_ok=True)
        
        # Create the virtual environment
        subprocess.run([sys.executable, "-m", "venv", str(venv_dir)], check=True)
        print_success("Virtual environment created successfully")
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to create virtual environment: {e}")
        return None
    except Exception as e:
        print_error(f"Unexpected error creating virtual environment: {e}")
        return None
    
    # Determine path to Python executable in the virtual environment
    if platform.system() == "Windows":
        venv_python = venv_dir / "Scripts" / "python.exe"
        venv_pip = venv_dir / "Scripts" / "pip.exe"
    else:
        venv_python = venv_dir / "bin" / "python"
        venv_pip = venv_dir / "bin" / "pip"
    
    if not venv_python.exists():
        print_error(f"Python executable not found in virtual environment: {venv_python}")
        return None
    
    # Verify the virtual environment is working
    try:
        # Run a simple check to verify the Python interpreter works
        version_output = subprocess.run(
            [str(venv_python), "--version"],
            check=True,
            capture_output=True,
            text=True
        ).stdout.strip()
        print_success(f"Virtual environment Python: {version_output}")
    except subprocess.CalledProcessError as e:
        print_error(f"Virtual environment Python executable is not functioning: {e}")
        return None
    
    return venv_python, venv_pip

def install_python_dependencies(venv_pip):
    print_header("Installing Python dependencies...")
    
    python_dir = Path(os.path.dirname(os.path.abspath(__file__))) / "python"
    requirements_file = python_dir / "requirements.txt"
    
    if not requirements_file.exists():
        print_error(f"Requirements file not found: {requirements_file}")
        return False
    
    try:
        subprocess.run(
            [str(venv_pip), "install", "-r", str(requirements_file)],
            check=True
        )
        print_success("Python dependencies installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to install Python dependencies: {e}")
        return False

def build_application(venv_python):
    print_header("Building the Sensor Graph Display application...")
    
    # Get the absolute path to the project directory
    project_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    build_dir = project_dir / "build"
    
    # Create build directory if it doesn't exist
    if not build_dir.exists():
        build_dir.mkdir()
    
    # Check if CMakeCache.txt exists and if it references a different path
    cache_file = build_dir / "CMakeCache.txt"
    force_clean_build = False
    
    if cache_file.exists():
        try:
            with open(cache_file, 'r') as f:
                cache_content = f.read()
            
            # Check if the cache contains references to a different path
            current_path_str = str(project_dir).replace('\\', '/')
            
            if current_path_str not in cache_content and any('CMAKE_HOME_DIRECTORY' in line for line in cache_content.splitlines()):
                print_info("Detected app has been moved to a new location.")
                print_info("Forcing a clean rebuild...")
                force_clean_build = True
                
                # Clean the build directory by removing the cache file and other CMake-generated files
                os.remove(cache_file)
                for item in ['CMakeFiles', 'cmake_install.cmake', 'Makefile']:
                    item_path = build_dir / item
                    if item_path.exists():
                        if item_path.is_dir():
                            shutil.rmtree(item_path)
                        else:
                            os.remove(item_path)
        except Exception as e:
            print_info(f"Note: Error checking CMake cache: {e}")
            # If we can't read the cache, better to force a clean build
            force_clean_build = True
    
    # Change to the build directory
    os.chdir(build_dir)
    
    # Prepare environment variables to use the virtual environment's Python
    env = os.environ.copy()
    env["PYTHON_EXECUTABLE"] = str(venv_python)
    
    # Run CMake
    print_info("Running CMake...")
    try:
        if force_clean_build:
            print_info("Configuring with clean build...")
            # Use -B to specify build directory and -S to specify source directory
            subprocess.run(["cmake", "-B", ".", "-S", ".."], check=True, env=env)
        else:
            subprocess.run(["cmake", ".."], check=True, env=env)
    except subprocess.CalledProcessError as e:
        print_error(f"CMake configuration failed: {e}")
        return False
    
    # Build the application
    print_info("Compiling...")
    try:
        # Use 'make' on Unix or 'cmake --build' on Windows
        if platform.system() == "Windows":
            subprocess.run(["cmake", "--build", "."], check=True)
        else:
            subprocess.run(["make", "-j4"], check=True)
    except subprocess.CalledProcessError as e:
        print_error(f"Build failed: {e}")
        return False
    
    print_success("Build completed successfully")
    return True

def run_application():
    print_header("Running Sensor Graph Display...")
    
    # Get the absolute path to the project directory
    project_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    
    # List of possible build directories, from most to least likely
    possible_build_dirs = [
        project_dir / "build",              # Standard build directory
        project_dir,                       # Build might be in the same directory
        project_dir / "build_tests",       # Test build directory
        project_dir.parent / "build",      # Build in parent directory
        Path(os.getcwd()) / "build"        # Build in current working directory
    ]
    
    # Find which build directory exists
    build_dir = None
    for path in possible_build_dirs:
        if path.exists():
            build_dir = path
            break
    
    if not build_dir:
        print_error("Could not find build directory. Please ensure the application is built.")
        return False
    
    print_info(f"Using build directory: {build_dir}")
    
    # Find executable based on platform
    executables = []
    
    if platform.system() == "Windows":
        # Windows executable possibilities
        executables = [
            build_dir / "SensorGraphDisplay.exe",
            build_dir / "Debug" / "SensorGraphDisplay.exe",
            build_dir / "Release" / "SensorGraphDisplay.exe"
        ]
    elif platform.system() == "Darwin":  # macOS
        # macOS executable possibilities (inside .app bundle)
        executables = [
            build_dir / "SensorGraphDisplay.app/Contents/MacOS/SensorGraphDisplay",
            project_dir / "SensorGraphDisplay.app/Contents/MacOS/SensorGraphDisplay",
            Path(f"{build_dir}/SensorGraphDisplay.app/Contents/MacOS/SensorGraphDisplay")
        ]
        
        # Also try looking for .app bundles recursively
        try:
            for root, dirs, files in os.walk(build_dir):
                for dir in dirs:
                    if dir.endswith(".app"):
                        app_path = Path(root) / dir / "Contents/MacOS/SensorGraphDisplay"
                        if app_path.exists():
                            executables.append(app_path)
        except Exception as e:
            print_info(f"Note: Error scanning for .app bundles: {e}")
    else:  # Linux
        # Linux executable possibilities
        executables = [
            build_dir / "SensorGraphDisplay",
            build_dir / "bin" / "SensorGraphDisplay"
        ]
    
    # Find the first executable that exists
    executable = None
    for exe in executables:
        if exe.exists():
            executable = exe
            print_success(f"Found executable at: {executable}")
            break
    
    if not executable:
        print_error("Could not find the application executable. Make sure the application is built correctly.")
        print_info("Searched for executables in:")
        for exe in executables:
            print_info(f"  - {exe}")
        return False
    
    # Ensure the executable has execute permissions on Unix-like systems
    if platform.system() != "Windows":
        try:
            os.chmod(executable, os.stat(executable).st_mode | 0o111)  # Add execute permission
        except Exception as e:
            print_info(f"Note: Could not set executable permissions: {e}")
    
    # Run the application
    try:
        print_info(f"Starting: {executable}")
        subprocess.run([str(executable)], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to run the application: {e}")
        return False
    except KeyboardInterrupt:
        print_info("Application stopped by user")
        return True

def main():
    print_header("\n" + "="*60)
    print_header("       SENSOR GRAPH DISPLAY APPLICATION LAUNCHER")
    print_header("="*60 + "\n")
    
    # Check dependencies
    if not check_dependencies():
        print_error("Missing required dependencies. Exiting.")
        sys.exit(1)
    
    # Setup virtual environment
    venv_result = setup_virtual_environment()
    if venv_result is None:
        print_error("Failed to set up virtual environment. Exiting.")
        sys.exit(1)
    
    venv_python, venv_pip = venv_result
    
    # Install Python dependencies in the virtual environment
    if not install_python_dependencies(venv_pip):
        print_error("Failed to install Python dependencies. Exiting.")
        sys.exit(1)
    
    # Build application using the virtual environment's Python
    if not build_application(venv_python):
        print_error("Build failed. Exiting.")
        sys.exit(1)
    
    # Run application
    if not run_application():
        print_error("Failed to run the application. Exiting.")
        sys.exit(1)

if __name__ == "__main__":
    main()
