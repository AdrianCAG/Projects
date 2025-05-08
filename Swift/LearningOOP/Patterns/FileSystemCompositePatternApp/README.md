# File System Composite Pattern App

A Swift console application that demonstrates the Composite design pattern by simulating a file system structure.

## Overview

This application simulates a file system with directories and files, allowing users to navigate, create, modify, and search through a hierarchical structure. The Composite pattern is used to treat individual objects (files) and compositions of objects (directories) uniformly.

## Design Pattern: Composite

The Composite pattern is a structural design pattern that lets you compose objects into tree structures to represent part-whole hierarchies. It allows clients to treat individual objects and compositions of objects uniformly.

### Key Components in This Implementation

1. **Component (FileSystemComponent)**: The abstract base interface for all elements in the file system hierarchy.
2. **Leaf (File)**: Represents individual objects (files) that have no children.
3. **Composite (Directory)**: Represents complex elements (directories) that can contain other elements (both files and directories).
4. **Client**: The code that works with the file system components.

## Project Structure

```
FileSystemCompositePatternApp/
├── Sources/
│   ├── FileSystemComponent.swift  # Component interface
│   ├── File.swift                 # Leaf implementation
│   ├── Directory.swift            # Composite implementation
│   ├── FileSystem.swift           # Main file system manager
│   ├── FilePermissions.swift      # Permissions model
│   ├── SearchCriteria.swift       # Search functionality
│   ├── CommandLineInterface.swift # User interface
│   └── main.swift                 # Application entry point
└── Package.swift                  # Swift package definition
```

## Features

- Create and navigate through a hierarchical file system structure
- Add, remove, and modify files and directories
- Search for files and directories based on various criteria:
  - By name
  - By size (greater than, less than, equal to)
  - By modification date
  - By owner
  - By permissions
- Display detailed file and directory information
- Manage file permissions (read, write, execute)
- Copy and move files between directories

## How the Composite Pattern is Applied

In this application:

1. `FileSystemComponent` is the component interface that defines common operations for both files and directories.
2. `File` is the leaf class that implements the component interface for individual objects.
3. `Directory` is the composite class that:
   - Implements the component interface
   - Maintains a collection of child components (both files and directories)
   - Delegates operations to child components when appropriate

This structure allows for:
- Treating files and directories uniformly through the common interface
- Building complex hierarchical structures
- Recursively performing operations on the entire structure

## Benefits of the Composite Pattern

1. **Simplified Client Code**: Clients can work with complex tree structures through a simple, uniform interface.
2. **Open/Closed Principle**: New component types can be added without changing existing code.
3. **Recursive Operations**: Operations can be applied recursively to the entire structure.
4. **Natural Representation**: The pattern naturally models hierarchical structures like file systems.

## Running the Application

To run the application:

```bash
cd /path/to/FileSystemCompositePatternApp
swift build
swift run
```

## Usage Example

The application allows you to:

1. Navigate through directories using commands like `cd` and `ls`
2. Create new files and directories with `mkdir` and `touch`
3. Modify file contents with `edit`
4. Search for files and directories using various criteria
5. Change permissions with `chmod`
6. Copy and move files with `cp` and `mv`

## Implementation Details

- The application uses Swift's object-oriented features to implement the Composite pattern.
- Each component (file or directory) maintains its own metadata (name, size, dates, permissions).
- Directory sizes are calculated recursively by summing the sizes of all contained components.
- Search operations traverse the hierarchy to find matching components.
- The console interface provides a familiar command-line experience similar to Unix/Linux systems.
