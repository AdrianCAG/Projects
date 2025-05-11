#!/bin/bash

# Script to build and run the Sensor Graph Display application using a virtual environment

# Set colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Sensor Graph Display Builder${NC}"
echo "------------------------"

# Check for dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"

# Check for Python
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python found:${NC} $PYTHON_VERSION"
else
    echo -e "${RED}✗ Python 3 not found. Please install Python 3.6 or newer.${NC}"
    exit 1
fi

# Check for Qt
if command -v qmake6 &>/dev/null || command -v qmake &>/dev/null; then
    QMAKE_CMD=$(command -v qmake6 || command -v qmake)
    echo -e "${GREEN}✓ Qt found:${NC} $QMAKE_CMD"
else
    echo -e "${RED}✗ Qt not found. Please install Qt 6.x or newer.${NC}"
    exit 1
fi

# Check for CMake
if command -v cmake &>/dev/null; then
    CMAKE_VERSION=$(cmake --version | head -n 1)
    echo -e "${GREEN}✓ CMake found:${NC} $CMAKE_VERSION"
else
    echo -e "${RED}✗ CMake not found. Please install CMake.${NC}"
    exit 1
fi

# Set up virtual environment
echo -e "\n${YELLOW}Setting up Python virtual environment...${NC}"
if [ -d "venv" ]; then
    echo "Virtual environment already exists."
else
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create virtual environment. Try installing with: pip3 install virtualenv${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to activate virtual environment.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Install Python dependencies in the virtual environment
echo -e "\n${YELLOW}Installing Python dependencies...${NC}"
cd python || exit 1
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to install Python dependencies.${NC}"
    deactivate
    exit 1
fi
echo -e "${GREEN}✓ Python dependencies installed${NC}"
cd ..

# Create build directory
echo -e "\n${YELLOW}Setting up build directory...${NC}"
if [ -d "build" ]; then
    echo "Build directory already exists. Cleaning..."
    rm -rf build/*
else
    mkdir build
fi

# Configure and build using CMake
echo -e "\n${YELLOW}Building application...${NC}"
cd build || exit 1
cmake ..
if [ $? -ne 0 ]; then
    echo -e "${RED}CMake configuration failed.${NC}"
    deactivate
    exit 1
fi

make -j4
if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed.${NC}"
    deactivate
    exit 1
fi

# Run the application (still with the virtual environment active)
echo -e "\n${GREEN}Build successful! Launching Sensor Graph Display...${NC}"
./SensorGraphDisplay

# Deactivate virtual environment when done
deactivate

exit 0
