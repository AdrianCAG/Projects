// Directory.swift - Composite class in the Composite Pattern

import Foundation

// Directory represents a composite node in the composite structure
class Directory: FileSystemComponent {
    let name: String
    let path: String
    let creationDate: Date
    var modificationDate: Date
    var owner: String
    var permissions: FilePermissions
    
    // Collection of child components (both files and directories)
    private var children: [FileSystemComponent] = []
    
    // Computed property to get the total size of the directory
    var size: Int {
        return children.reduce(0) { $0 + $1.size }
    }
    
    // Initialize a directory
    init(name: String, parentPath: String, owner: String, permissions: FilePermissions = .readWrite) {
        self.name = name
        self.path = parentPath.isEmpty ? "/\(name)" : "\(parentPath)/\(name)"
        self.creationDate = Date()
        self.modificationDate = self.creationDate
        self.owner = owner
        self.permissions = permissions
    }
    
    // Display directory and its contents
    func display(indentation: Int) {
        let indent = String(repeating: "  ", count: indentation)
        let sizeStr = formatSize(size: size)
        print("\(indent)📁 \(name) (\(sizeStr)) [\(permissions.toString())]")
        
        // Display all children with increased indentation
        for child in children {
            child.display(indentation: indentation + 1)
        }
    }
    
    // Search directory and its contents based on criteria
    func search(criteria: SearchCriteria) -> [FileSystemComponent] {
        var results: [FileSystemComponent] = []
        
        // Check if this directory matches the criteria
        switch criteria.type {
        case .name:
            if name.lowercased().contains(criteria.value.lowercased()) {
                results.append(self)
            }
        case .size(let comparison, let value):
            switch comparison {
            case .greaterThan:
                if size > value {
                    results.append(self)
                }
            case .lessThan:
                if size < value {
                    results.append(self)
                }
            case .equalTo:
                if size == value {
                    results.append(self)
                }
            }
        case .modifiedAfter(let date):
            if modificationDate > date {
                results.append(self)
            }
        case .modifiedBefore(let date):
            if modificationDate < date {
                results.append(self)
            }
        case .owner:
            if owner.lowercased() == criteria.value.lowercased() {
                results.append(self)
            }
        case .permissions(let required):
            if permissions.contains(required) {
                results.append(self)
            }
        case .contentContains:
            // Directories don't have content, so this criteria doesn't apply
            break
        }
        
        // Recursively search all children
        for child in children {
            results.append(contentsOf: child.search(criteria: criteria))
        }
        
        return results
    }
    
    // Delete directory and all its contents
    func delete() -> Bool {
        // Delete all children first
        for child in children {
            _ = child.delete()
        }
        
        print("🗑️ Deleted directory: \(path)")
        return true
    }
    
    // Copy directory and all its contents to destination
    func copy(to destination: String) -> FileSystemComponent? {
        let newDir = Directory(name: name, parentPath: destination, owner: owner, permissions: permissions)
        newDir.modificationDate = Date()
        
        // Copy all children
        for child in children {
            if let copiedChild = child.copy(to: newDir.path) {
                newDir.add(component: copiedChild)
            }
        }
        
        print("📋 Copied directory from \(path) to \(destination)/\(name)")
        return newDir
    }
    
    // Move directory to destination
    func move(to destination: String) -> Bool {
        print("✂️ Moved directory from \(path) to \(destination)/\(name)")
        return true
    }
    
    // Add a component to this directory
    func add(component: FileSystemComponent) {
        children.append(component)
        modificationDate = Date()
    }
    
    // Remove a component from this directory
    func remove(componentName: String) -> Bool {
        if let index = children.firstIndex(where: { $0.name == componentName }) {
            children.remove(at: index)
            modificationDate = Date()
            return true
        }
        return false
    }
    
    // Get a component by name
    func getComponent(name: String) -> FileSystemComponent? {
        return children.first { $0.name == name }
    }
    
    // Get all components
    func getComponents() -> [FileSystemComponent] {
        return children
    }
    
    // Get all files (not directories)
    func getFiles() -> [File] {
        return children.compactMap { $0 as? File }
    }
    
    // Get all subdirectories
    func getDirectories() -> [Directory] {
        return children.compactMap { $0 as? Directory }
    }
    
    // Create a new file in this directory
    func createFile(name: String, content: String) -> File? {
        // Check if a component with this name already exists
        if getComponent(name: name) != nil {
            print("⚠️ A component with name '\(name)' already exists in this directory")
            return nil
        }
        
        // Create the new file
        let newFile = File(name: name, parentPath: path, textContent: content, owner: owner)
        add(component: newFile)
        return newFile
    }
    
    // Create a new subdirectory in this directory
    func createDirectory(name: String) -> Directory? {
        // Check if a component with this name already exists
        if getComponent(name: name) != nil {
            print("⚠️ A component with name '\(name)' already exists in this directory")
            return nil
        }
        
        // Create the new directory
        let newDir = Directory(name: name, parentPath: path, owner: owner)
        add(component: newDir)
        return newDir
    }
    
    // Find a component by path (relative to this directory)
    func findByPath(_ relativePath: String) -> FileSystemComponent? {
        let pathComponents = relativePath.split(separator: "/")
        
        // Base case: empty path means this directory
        if pathComponents.isEmpty {
            return self
        }
        
        // Get the first component
        let firstComponent = String(pathComponents[0])
        
        // If this is the only component, look for it directly
        if pathComponents.count == 1 {
            return getComponent(name: firstComponent)
        }
        
        // Otherwise, we need to recurse into the subdirectory
        if let subdir = getComponent(name: firstComponent) as? Directory {
            // Build the remaining path
            let remainingPath = pathComponents[1...].joined(separator: "/")
            return subdir.findByPath(remainingPath)
        }
        
        // If we get here, the path is invalid
        return nil
    }
}
