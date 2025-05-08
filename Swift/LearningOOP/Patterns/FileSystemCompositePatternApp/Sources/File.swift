// File.swift - Leaf class in the Composite Pattern

import Foundation

// File represents a leaf node in the composite structure
class File: FileSystemComponent {
    let name: String
    let path: String
    let creationDate: Date
    var modificationDate: Date
    var owner: String
    var permissions: FilePermissions
    private var fileContent: Data
    private var fileType: FileType
    
    // Computed property to get the file size
    var size: Int {
        return fileContent.count
    }
    
    // File type enum
    enum FileType: String {
        case text = "txt"
        case image = "img"
        case audio = "aud"
        case video = "vid"
        case document = "doc"
        case executable = "exe"
        case unknown = "unk"
        
        // Get file type from extension
        static func fromExtension(_ ext: String) -> FileType {
            switch ext.lowercased() {
            case "txt", "md", "rtf", "csv":
                return .text
            case "jpg", "jpeg", "png", "gif", "bmp", "svg":
                return .image
            case "mp3", "wav", "aac", "flac", "ogg":
                return .audio
            case "mp4", "mov", "avi", "mkv", "wmv":
                return .video
            case "doc", "docx", "pdf", "xls", "xlsx", "ppt", "pptx":
                return .document
            case "exe", "app", "sh", "bat", "bin":
                return .executable
            default:
                return .unknown
            }
        }
        
        // Get icon for file type
        func getIcon() -> String {
            switch self {
            case .text:
                return "📄"
            case .image:
                return "🖼️"
            case .audio:
                return "🎵"
            case .video:
                return "🎬"
            case .document:
                return "📑"
            case .executable:
                return "⚙️"
            case .unknown:
                return "❓"
            }
        }
    }
    
    // Initialize a file with content
    init(name: String, parentPath: String, content: Data, owner: String, permissions: FilePermissions = .readWrite) {
        self.name = name
        self.path = parentPath.isEmpty ? "/\(name)" : "\(parentPath)/\(name)"
        self.creationDate = Date()
        self.modificationDate = self.creationDate
        self.owner = owner
        self.permissions = permissions
        self.fileContent = content
        
        // Determine file type from extension
        let fileExtension = (name as NSString).pathExtension
        self.fileType = FileType.fromExtension(fileExtension)
    }
    
    // Initialize a file with string content
    convenience init(name: String, parentPath: String, textContent: String, owner: String, permissions: FilePermissions = .readWrite) {
        let data = textContent.data(using: .utf8) ?? Data()
        self.init(name: name, parentPath: parentPath, content: data, owner: owner, permissions: permissions)
    }
    
    // Display file information
    func display(indentation: Int) {
        let indent = String(repeating: "  ", count: indentation)
        let icon = fileType.getIcon()
        let sizeStr = formatSize(size: size)
        print("\(indent)\(icon) \(name) (\(sizeStr)) [\(permissions.toString())]")
    }
    
    // Search file based on criteria
    func search(criteria: SearchCriteria) -> [FileSystemComponent] {
        switch criteria.type {
        case .name:
            if name.lowercased().contains(criteria.value.lowercased()) {
                return [self]
            }
        case .size(let comparison, let value):
            switch comparison {
            case .greaterThan:
                if size > value {
                    return [self]
                }
            case .lessThan:
                if size < value {
                    return [self]
                }
            case .equalTo:
                if size == value {
                    return [self]
                }
            }
        case .modifiedAfter(let date):
            if modificationDate > date {
                return [self]
            }
        case .modifiedBefore(let date):
            if modificationDate < date {
                return [self]
            }
        case .owner:
            if owner.lowercased() == criteria.value.lowercased() {
                return [self]
            }
        case .permissions(let required):
            if permissions.contains(required) {
                return [self]
            }
        case .contentContains(let text):
            if let stringContent = String(data: fileContent, encoding: .utf8),
               stringContent.lowercased().contains(text.lowercased()) {
                return [self]
            }
        }
        return []
    }
    
    // Delete file
    func delete() -> Bool {
        print("🗑️ Deleted file: \(path)")
        return true
    }
    
    // Copy file to destination
    func copy(to destination: String) -> FileSystemComponent? {
        let newPath = destination
        let newFile = File(name: name, parentPath: destination, content: fileContent, owner: owner, permissions: permissions)
        newFile.modificationDate = Date()
        print("📋 Copied file from \(path) to \(newPath)/\(name)")
        return newFile
    }
    
    // Move file to destination
    func move(to destination: String) -> Bool {
        print("✂️ Moved file from \(path) to \(destination)/\(name)")
        return true
    }
    
    // Get file content as string if possible
    func getContentAsString() -> String? {
        return String(data: fileContent, encoding: .utf8)
    }
    
    // Update file content
    func updateContent(_ newContent: Data) {
        fileContent = newContent
        modificationDate = Date()
    }
    
    // Update file content with string
    func updateContent(_ newContent: String) {
        if let data = newContent.data(using: .utf8) {
            updateContent(data)
        }
    }
    
    // Append content to file
    func appendContent(_ additionalContent: Data) {
        fileContent.append(additionalContent)
        modificationDate = Date()
    }
    
    // Append string content to file
    func appendContent(_ additionalContent: String) {
        if let data = additionalContent.data(using: .utf8) {
            appendContent(data)
        }
    }
}
