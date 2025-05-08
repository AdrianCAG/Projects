// FileSystemCommander.swift - Command-line interface for the FileSystem

import Foundation

// FileSystemCommander provides a command-line interface for interacting with the file system
class FileSystemCommander {
    private let fileSystem: FileSystem
    private var isRunning = false
    
    // Initialize with a file system
    init(fileSystem: FileSystem) {
        self.fileSystem = fileSystem
    }
    
    // Start the command-line interface
    func start() {
        isRunning = true
        
        print("=== File System Composite Pattern Demo ===")
        print("Type 'help' for a list of commands")
        
        while isRunning {
            // Display the prompt with current directory
            print("\n\(fileSystem.getCurrentPath())> ", terminator: "")
            
            // Read user input
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            
            // Skip empty input
            if input.isEmpty {
                continue
            }
            
            // Parse and execute the command
            executeCommand(input)
        }
    }
    
    // Parse and execute a command
    private func executeCommand(_ input: String) {
        // Split the input into command and arguments
        let components = input.split(separator: " ", maxSplits: 1)
        let command = String(components[0]).lowercased()
        let arguments = components.count > 1 ? String(components[1]) : ""
        
        switch command {
        case "help":
            displayHelp()
        case "ls":
            if arguments.contains("-l") {
                fileSystem.listContentsDetailed()
            } else {
                fileSystem.listContents()
            }
        case "cd":
            if arguments.isEmpty {
                print("⚠️ Usage: cd <directory>")
            } else {
                if !fileSystem.changeDirectory(path: arguments) {
                    print("⚠️ Failed to change directory to \(arguments)")
                }
            }
        case "pwd":
            print(fileSystem.getCurrentPath())
        case "mkdir":
            if arguments.isEmpty {
                print("⚠️ Usage: mkdir <directory_name>")
            } else {
                if fileSystem.createDirectory(name: arguments) {
                    print("✅ Created directory: \(arguments)")
                }
            }
        case "touch":
            if arguments.isEmpty {
                print("⚠️ Usage: touch <file_name>")
            } else {
                if fileSystem.createFile(name: arguments, content: "") {
                    print("✅ Created empty file: \(arguments)")
                }
            }
        case "cat":
            if arguments.isEmpty {
                print("⚠️ Usage: cat <file_path>")
            } else {
                if let content = fileSystem.readFile(path: arguments) {
                    print("=== Content of \(arguments) ===")
                    print(content)
                    print("=== End of file ===")
                }
            }
        case "write":
            handleWriteCommand(arguments)
        case "rm":
            if arguments.isEmpty {
                print("⚠️ Usage: rm <name>")
            } else {
                if fileSystem.delete(name: arguments) {
                    print("✅ Deleted: \(arguments)")
                } else {
                    print("⚠️ Failed to delete: \(arguments)")
                }
            }
        case "find":
            handleFindCommand(arguments)
        case "tree":
            fileSystem.displayTree()
        case "size":
            print("Total file system size: \(fileSystem.getFormattedTotalSize())")
        case "exit", "quit":
            isRunning = false
            print("Goodbye!")
        default:
            print("⚠️ Unknown command: \(command)")
            print("Type 'help' for a list of commands")
        }
    }
    
    // Handle the write command
    private func handleWriteCommand(_ arguments: String) {
        // Split the arguments into file path and content
        let components = arguments.split(separator: " ", maxSplits: 1)
        
        if components.count < 2 {
            print("⚠️ Usage: write <file_path> <content>")
            return
        }
        
        let filePath = String(components[0])
        let content = String(components[1])
        
        if fileSystem.writeFile(path: filePath, content: content) {
            print("✅ Content written to \(filePath)")
        } else {
            print("⚠️ Failed to write to \(filePath)")
        }
    }
    
    // Handle the find command
    private func handleFindCommand(_ arguments: String) {
        // Split the arguments into search type and value
        let components = arguments.split(separator: " ", maxSplits: 1)
        
        if components.count < 2 {
            print("⚠️ Usage: find <type> <value>")
            print("Types: name, size, owner, content")
            return
        }
        
        let searchType = String(components[0]).lowercased()
        let searchValue = String(components[1])
        
        var criteria: SearchCriteria
        
        switch searchType {
        case "name":
            criteria = SearchCriteria.byName(searchValue)
        case "size":
            if let size = Int(searchValue) {
                criteria = SearchCriteria.bySize(comparison: .greaterThan, size: size)
            } else {
                print("⚠️ Size must be a number")
                return
            }
        case "owner":
            criteria = SearchCriteria.byOwner(searchValue)
        case "content":
            criteria = SearchCriteria.contentContains(text: searchValue)
        default:
            print("⚠️ Unknown search type: \(searchType)")
            print("Types: name, size, owner, content")
            return
        }
        
        let results = fileSystem.search(criteria: criteria)
        
        if results.isEmpty {
            print("No results found")
        } else {
            print("Found \(results.count) results:")
            for result in results {
                print("- \(result.path) (\(result is Directory ? "Directory" : "File"))")
            }
        }
    }
    
    // Display help information
    private func displayHelp() {
        print("""
        === Available Commands ===
        help                    - Display this help message
        ls                      - List contents of current directory
        ls -l                   - List contents with details
        cd <directory>          - Change to directory
        pwd                     - Print current directory
        mkdir <directory_name>  - Create a new directory
        touch <file_name>       - Create an empty file
        cat <file_path>         - Display file contents
        write <file_path> <content> - Write content to a file
        rm <name>               - Delete a file or directory
        find <type> <value>     - Search for files/directories
                                  Types: name, size, owner, content
        tree                    - Display the file system tree
        size                    - Display total file system size
        exit, quit              - Exit the program
        """)
    }
}
