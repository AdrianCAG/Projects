#!/bin/bash

# Script to clean up build directories
# This will clean both the shared-build directory and individual .build directories in Swift projects

BASE_DIR="$(pwd)"
SHARED_BUILD_DIR="$BASE_DIR/shared-build"
PROJECT_DIRS=(
    "AdvancedToProfessional/CloudSyncPlatform"
    "EasyToMedium/LibraryApp"
    "EasyToMedium/PetCareApp"
    "EasyToMedium/TaskManagerApp"
    "MediumToAdvanced/WeatherDashboard"
    "Patterns/CoffeeShopDecoratorPatternApp"
    "Patterns/FileSystemCompositePatternApp"
    "Patterns/GameCharacterFactoryPatternApp"
    "Patterns/MediaLibraryAdapterPatternApp"
    "Patterns/SecureAPIProxyPatternApp"
    "Patterns/SingletonWeatherApp"
    "Patterns/SmartHomeFacadePatternApp"
)

echo "This script will clean:"
echo "1. Everything inside the shared-build directory"
echo "2. All .build directories in Swift projects"
echo "WARNING: This will remove all compiled files and cached dependencies."
echo "You will need to rebuild your projects after running this script."
read -p "Are you sure you want to continue? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Clean shared-build directory
if [ -d "$SHARED_BUILD_DIR" ]; then
    echo "Calculating space used by shared-build directory..."
    SHARED_SIZE=$(du -sh "$SHARED_BUILD_DIR" | awk '{print $1}')
    echo "Shared build directory is using approximately $SHARED_SIZE of disk space."
    echo "Cleaning shared build directory..."
    rm -rf "$SHARED_BUILD_DIR"/*
    mkdir -p "$SHARED_BUILD_DIR"
    echo "✅ Shared build directory cleaned successfully."
else
    echo "⚠️ Shared build directory not found at $SHARED_BUILD_DIR. Creating it..."
    mkdir -p "$SHARED_BUILD_DIR"
fi

# Clean individual project .build directories
echo "Cleaning individual project .build directories..."
CLEANED_COUNT=0

for PROJECT_DIR in "${PROJECT_DIRS[@]}"; do
    FULL_PROJECT_PATH="$BASE_DIR/$PROJECT_DIR"
    BUILD_DIR="$FULL_PROJECT_PATH/.build"
    
    if [ -d "$BUILD_DIR" ]; then
        echo "Cleaning $PROJECT_DIR/.build..."
        rm -rf "$BUILD_DIR"
        CLEANED_COUNT=$((CLEANED_COUNT + 1))
    fi
done

echo "✅ Cleaned $CLEANED_COUNT project build directories."
echo "Cleanup complete! All build directories have been reset."
echo "Your next builds will start from a fresh state."
