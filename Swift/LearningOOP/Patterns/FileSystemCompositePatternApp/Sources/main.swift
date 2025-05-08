// main.swift - Entry point for the FileSystemCompositePatternApp

import Foundation

// Print a welcome banner
print("""
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║             File System Composite Pattern Demo                 ║
║                                                                ║
║  This application demonstrates the Composite Design Pattern    ║
║  by implementing a virtual file system where both files and    ║
║  directories share a common interface, allowing them to be     ║
║  treated uniformly.                                            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
""")

// Get the current user's name for the file system
let userName = ProcessInfo.processInfo.environment["USER"] ?? "user"

// Create the file system
let fileSystem = FileSystem(rootOwner: userName)

// Create a commander to interact with the file system
let commander = FileSystemCommander(fileSystem: fileSystem)

// Demonstrate the Composite pattern
print("\nDemonstrating the Composite Pattern:")
print("-----------------------------------")
print("The Composite Pattern allows you to compose objects into tree structures")
print("to represent part-whole hierarchies. It lets clients treat individual")
print("objects and compositions of objects uniformly.")
print("\nIn this application:")
print("- FileSystemComponent is the Component interface")
print("- File is the Leaf class")
print("- Directory is the Composite class")
print("- FileSystem is the Client that uses the composite structure")

print("\nHere's the initial file system structure:")
fileSystem.displayTree()

print("\nNow you can interact with the file system using various commands.")
print("Type 'help' to see available commands.")

// Start the interactive commander
commander.start()
