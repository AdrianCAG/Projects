// FileSystemComponent.swift - Component interface for the Composite Pattern

import Foundation

// The Component interface declares common operations for both simple and complex objects
protocol FileSystemComponent {
    var name: String { get }
    var path: String { get }
    var creationDate: Date { get }
    var modificationDate: Date { get set }
    var size: Int { get }
    var owner: String { get set }
    var permissions: FilePermissions { get set }
    
    // Operations
    func display(indentation: Int)
    func search(criteria: SearchCriteria) -> [FileSystemComponent]
    func delete() -> Bool
    func copy(to destination: String) -> FileSystemComponent?
    func move(to destination: String) -> Bool
}

// File permissions structure
struct FilePermissions: OptionSet {
    let rawValue: Int
    
    static let read = FilePermissions(rawValue: 1 << 0)
    static let write = FilePermissions(rawValue: 1 << 1)
    static let execute = FilePermissions(rawValue: 1 << 2)
    
    // Common permission combinations
    static let readOnly: FilePermissions = [.read]
    static let readWrite: FilePermissions = [.read, .write]
    static let readWriteExecute: FilePermissions = [.read, .write, .execute]
    
    func toString() -> String {
        var result = ""
        result += contains(.read) ? "r" : "-"
        result += contains(.write) ? "w" : "-"
        result += contains(.execute) ? "x" : "-"
        return result
    }
}

// Search criteria for finding files and directories
struct SearchCriteria {
    enum CriteriaType {
        case name
        case size(comparison: SizeComparison, value: Int)
        case modifiedAfter(date: Date)
        case modifiedBefore(date: Date)
        case owner
        case permissions(required: FilePermissions)
        case contentContains(text: String)
    }
    
    enum SizeComparison {
        case greaterThan
        case lessThan
        case equalTo
    }
    
    let type: CriteriaType
    let value: String
    
    // Factory methods for creating different search criteria
    static func byName(_ name: String) -> SearchCriteria {
        return SearchCriteria(type: .name, value: name)
    }
    
    static func bySize(comparison: SizeComparison, size: Int) -> SearchCriteria {
        return SearchCriteria(type: .size(comparison: comparison, value: size), value: "\(size)")
    }
    
    static func modifiedAfter(date: Date) -> SearchCriteria {
        return SearchCriteria(type: .modifiedAfter(date: date), value: "\(date)")
    }
    
    static func modifiedBefore(date: Date) -> SearchCriteria {
        return SearchCriteria(type: .modifiedBefore(date: date), value: "\(date)")
    }
    
    static func byOwner(_ owner: String) -> SearchCriteria {
        return SearchCriteria(type: .owner, value: owner)
    }
    
    static func byPermissions(required: FilePermissions) -> SearchCriteria {
        return SearchCriteria(type: .permissions(required: required), value: required.toString())
    }
    
    static func contentContains(text: String) -> SearchCriteria {
        return SearchCriteria(type: .contentContains(text: text), value: text)
    }
}

// Extension to add common functionality to all file system components
extension FileSystemComponent {
    // Default implementation for path construction
    func constructPath(parentPath: String) -> String {
        if parentPath.isEmpty || parentPath == "/" {
            return "/\(name)"
        } else {
            return "\(parentPath)/\(name)"
        }
    }
    
    // Format size for display
    func formatSize(size: Int) -> String {
        let kb = 1024
        let mb = kb * 1024
        let gb = mb * 1024
        
        if size < kb {
            return "\(size) bytes"
        } else if size < mb {
            let sizeInKB = Double(size) / Double(kb)
            return String(format: "%.2f KB", sizeInKB)
        } else if size < gb {
            let sizeInMB = Double(size) / Double(mb)
            return String(format: "%.2f MB", sizeInMB)
        } else {
            let sizeInGB = Double(size) / Double(gb)
            return String(format: "%.2f GB", sizeInGB)
        }
    }
    
    // Format date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
