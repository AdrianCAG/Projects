// FileSystem.swift - Client interface for the Composite Pattern

import Foundation

// FileSystem class provides a high-level interface to work with the file system
class FileSystem {
    // Root directory of the file system
    private let root: Directory
    
    // Current working directory
    private var currentDirectory: Directory
    
    // Initialize the file system
    init(rootOwner: String) {
        // Create the root directory
        root = Directory(name: "", parentPath: "", owner: rootOwner, permissions: .readWriteExecute)
        currentDirectory = root
        
        // Set up initial file system structure
        setupInitialStructure()
    }
    
    // Set up the initial file system structure with some sample directories and files
    private func setupInitialStructure() {
        // Create home directory
        let home = Directory(name: "home", parentPath: "", owner: root.owner, permissions: .readWriteExecute)
        root.add(component: home)
        
        // Create user directory
        let user = Directory(name: root.owner, parentPath: "/home", owner: root.owner, permissions: .readWriteExecute)
        home.add(component: user)
        
        // Create some standard directories
        let documents = Directory(name: "Documents", parentPath: "/home/\(root.owner)", owner: root.owner, permissions: .readWriteExecute)
        let pictures = Directory(name: "Pictures", parentPath: "/home/\(root.owner)", owner: root.owner, permissions: .readWriteExecute)
        let music = Directory(name: "Music", parentPath: "/home/\(root.owner)", owner: root.owner, permissions: .readWriteExecute)
        let videos = Directory(name: "Videos", parentPath: "/home/\(root.owner)", owner: root.owner, permissions: .readWriteExecute)
        
        user.add(component: documents)
        user.add(component: pictures)
        user.add(component: music)
        user.add(component: videos)
        
        // Add some sample files
        let readme = File(name: "README.txt", parentPath: "/home/\(root.owner)/Documents", 
                          textContent: "Welcome to the File System Composite Pattern Demo!", 
                          owner: root.owner)
        documents.add(component: readme)
        
        let notes = File(name: "notes.txt", parentPath: "/home/\(root.owner)/Documents", 
                         textContent: "The Composite Pattern allows you to compose objects into tree structures to represent part-whole hierarchies.", 
                         owner: root.owner)
        documents.add(component: notes)
        
        let image = File(name: "sample.jpg", parentPath: "/home/\(root.owner)/Pictures", 
                         textContent: "[Binary image data]", 
                         owner: root.owner)
        pictures.add(component: image)
        
        // Create a projects directory with some code files
        let projects = Directory(name: "Projects", parentPath: "/home/\(root.owner)/Documents", owner: root.owner, permissions: .readWriteExecute)
        documents.add(component: projects)
        
        let compositeExample = File(name: "CompositePattern.swift", parentPath: "/home/\(root.owner)/Documents/Projects", 
                                    textContent: """
                                    protocol Component {
                                        func operation()
                                    }
                                    
                                    class Leaf: Component {
                                        func operation() {
                                            print("Leaf operation")
                                        }
                                    }
                                    
                                    class Composite: Component {
                                        private var children: [Component] = []
                                        
                                        func add(component: Component) {
                                            children.append(component)
                                        }
                                        
                                        func operation() {
                                            print("Composite operation")
                                            for child in children {
                                                child.operation()
                                            }
                                        }
                                    }
                                    """, 
                                    owner: root.owner)
        projects.add(component: compositeExample)
    }
    
    // Get the current working directory path
    func getCurrentPath() -> String {
        return currentDirectory.path.isEmpty ? "/" : currentDirectory.path
    }
    
    // Change the current directory
    func changeDirectory(path: String) -> Bool {
        // Handle special paths
        if path == "/" {
            currentDirectory = root
            return true
        } else if path == ".." {
            // Move up one level
            let parentPath = String(currentDirectory.path.dropLast(currentDirectory.name.count + 1))
            if parentPath.isEmpty {
                currentDirectory = root
            } else if let parent = findComponent(path: parentPath) as? Directory {
                currentDirectory = parent
            } else {
                print("⚠️ Invalid parent directory")
                return false
            }
            return true
        }
        
        // Handle absolute paths
        if path.starts(with: "/") {
            if let dir = findComponent(path: path) as? Directory {
                currentDirectory = dir
                return true
            } else {
                print("⚠️ Directory not found: \(path)")
                return false
            }
        }
        
        // Handle relative paths
        let fullPath = currentDirectory.path.isEmpty ? "/\(path)" : "\(currentDirectory.path)/\(path)"
        if let dir = findComponent(path: fullPath) as? Directory {
            currentDirectory = dir
            return true
        } else {
            print("⚠️ Directory not found: \(fullPath)")
            return false
        }
    }
    
    // List the contents of the current directory
    func listContents() {
        print("Contents of \(getCurrentPath()):")
        for component in currentDirectory.getComponents() {
            if let dir = component as? Directory {
                print("📁 \(dir.name)/")
            } else if let file = component as? File {
                print("\(file.name)")
            }
        }
    }
    
    // List the contents of the current directory with details
    func listContentsDetailed() {
        print("Contents of \(getCurrentPath()):")
        currentDirectory.display(indentation: 0)
    }
    
    // Create a new file in the current directory
    func createFile(name: String, content: String) -> Bool {
        if currentDirectory.createFile(name: name, content: content) != nil {
            print("✅ Created file: \(name)")
            return true
        } else {
            return false
        }
    }
    
    // Create a new directory in the current directory
    func createDirectory(name: String) -> Bool {
        if currentDirectory.createDirectory(name: name) != nil {
            print("✅ Created directory: \(name)")
            return true
        } else {
            return false
        }
    }
    
    // Delete a file or directory in the current directory
    func delete(name: String) -> Bool {
        if let component = currentDirectory.getComponent(name: name) {
            if component.delete() {
                return currentDirectory.remove(componentName: name)
            }
        }
        print("⚠️ Component not found: \(name)")
        return false
    }
    
    // Find a component by path
    func findComponent(path: String) -> FileSystemComponent? {
        // Handle root path
        if path == "/" {
            return root
        }
        
        // Remove leading slash if present
        let cleanPath = path.starts(with: "/") ? String(path.dropFirst()) : path
        
        // Split the path into components
        let pathComponents = cleanPath.split(separator: "/")
        
        // Start from the root
        var current: FileSystemComponent = root
        
        // Traverse the path
        for component in pathComponents {
            let name = String(component)
            
            // If current is a directory, look for the child component
            if let dir = current as? Directory {
                if let child = dir.getComponent(name: name) {
                    current = child
                } else {
                    print("⚠️ Component not found: \(name) in \(dir.path)")
                    return nil
                }
            } else {
                // If current is not a directory, we can't traverse further
                print("⚠️ Not a directory: \(current.path)")
                return nil
            }
        }
        
        return current
    }
    
    // Read the content of a file
    func readFile(path: String) -> String? {
        if let file = findComponent(path: path) as? File {
            if file.permissions.contains(.read) {
                return file.getContentAsString() ?? "[Binary data]"
            } else {
                print("⚠️ Permission denied: Cannot read \(file.path)")
                return nil
            }
        } else {
            print("⚠️ File not found: \(path)")
            return nil
        }
    }
    
    // Write content to a file
    func writeFile(path: String, content: String, append: Bool = false) -> Bool {
        if let file = findComponent(path: path) as? File {
            if file.permissions.contains(.write) {
                if append {
                    file.appendContent(content)
                } else {
                    file.updateContent(content)
                }
                return true
            } else {
                print("⚠️ Permission denied: Cannot write to \(file.path)")
                return false
            }
        } else {
            print("⚠️ File not found: \(path)")
            return false
        }
    }
    
    // Search for files and directories matching criteria
    func search(criteria: SearchCriteria) -> [FileSystemComponent] {
        return root.search(criteria: criteria)
    }
    
    // Display the file system tree
    func displayTree() {
        print("File System Tree:")
        root.display(indentation: 0)
    }
    
    // Get the total size of the file system
    func getTotalSize() -> Int {
        return root.size
    }
    
    // Format the total size for display
    func getFormattedTotalSize() -> String {
        return root.formatSize(size: root.size)
    }
}
