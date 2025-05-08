#!/bin/bash

# Script to build Swift projects using a shared build directory
# Usage: ./build-project.sh <project-directory> [swift-command]

if [ -z "$1" ]; then
    echo "Error: Project directory not specified"
    echo "Usage: ./build-project.sh <project-directory> [swift-command]"
    exit 1
fi

PROJECT_DIR="$1"
BASE_DIR="$(pwd)"
SHARED_BUILD_DIR="$BASE_DIR/shared-build"
COMMAND="${2:-build}"  # Default command is 'build' if not specified

# Create shared build directory if it doesn't exist
mkdir -p "$SHARED_BUILD_DIR"

# Check if the project directory exists and contains a Package.swift file
if [ ! -d "$PROJECT_DIR" ] || [ ! -f "$PROJECT_DIR/Package.swift" ]; then
    echo "Error: $PROJECT_DIR is not a valid Swift package directory"
    exit 1
fi

# Get the package name from Package.swift
PACKAGE_NAME=$(grep -m 1 "name:" "$PROJECT_DIR/Package.swift" | sed -E 's/.*name: *"([^"]+)".*/\1/')
echo "Package name: $PACKAGE_NAME"

# Clean the shared build directory for this package to avoid conflicts
echo "Cleaning previous build artifacts for $PACKAGE_NAME..."
rm -rf "$SHARED_BUILD_DIR/$PACKAGE_NAME"

# Handle mixed directory structures (files both in Sources/ and Sources/PackageName/)
if [ -d "$PROJECT_DIR/Sources" ]; then
    # Check if there are Swift files directly in Sources
    DIRECT_SWIFT_FILES=$(find "$PROJECT_DIR/Sources" -maxdepth 1 -name "*.swift" | wc -l)
    
    # Check if the package directory exists
    if [ -d "$PROJECT_DIR/Sources/$PACKAGE_NAME" ]; then
        # Mixed structure detected - files in both places
        if [ $DIRECT_SWIFT_FILES -gt 0 ]; then
            echo "Mixed directory structure detected (files in both Sources/ and Sources/$PACKAGE_NAME/)"
            echo "Creating temporary directory structure for clean build..."
            
            # Create a temporary directory for the build
            TEMP_DIR="$BASE_DIR/temp_build_$PACKAGE_NAME"
            mkdir -p "$TEMP_DIR/Sources/$PACKAGE_NAME"
            
            # Copy all Swift files to the temporary directory
            cp "$PROJECT_DIR/Sources/"*.swift "$TEMP_DIR/Sources/$PACKAGE_NAME/" 2>/dev/null || true
            cp -r "$PROJECT_DIR/Sources/$PACKAGE_NAME/"* "$TEMP_DIR/Sources/$PACKAGE_NAME/" 2>/dev/null || true
            
            # Copy Package.swift
            cp "$PROJECT_DIR/Package.swift" "$TEMP_DIR/"
            
            # Use the temporary directory for build
            BUILD_DIR="$TEMP_DIR"
            USING_TEMP=true
            
            echo "Temporary directory structure created for build"
        fi
    fi
fi

# Set the directory to use for building
BUILD_DIR="${BUILD_DIR:-$PROJECT_DIR}"

echo "Building project $BUILD_DIR using shared build directory"
echo "Command: swift $COMMAND --package-path $BUILD_DIR --build-path $SHARED_BUILD_DIR"

# Execute the Swift command with the shared build path
if [ "$COMMAND" = "run" ]; then
    # For 'run' command, we need to execute with the correct working directory
    cd "$BUILD_DIR"
    swift $COMMAND --build-path "$SHARED_BUILD_DIR"
    EXIT_CODE=$?
    cd "$BASE_DIR"
else
    # For other commands like 'build', 'test', etc.
    swift $COMMAND --package-path "$BUILD_DIR" --build-path "$SHARED_BUILD_DIR"
    EXIT_CODE=$?
fi

# Clean up temporary directory if we created one
if [ "$USING_TEMP" = true ]; then
    echo "Cleaning up temporary build directory..."
    rm -rf "$TEMP_DIR"
fi

# Return the exit code from the swift command
echo "Build completed with exit code: $EXIT_CODE"
exit $EXIT_CODE
