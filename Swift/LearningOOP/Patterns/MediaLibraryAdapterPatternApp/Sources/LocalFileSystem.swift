// LocalFileSystem.swift - Incompatible interface (Adaptee) for local files

import Foundation

// File format enum
enum FileFormat: String {
    // Audio formats
    case mp3 = "MP3"
    case wav = "WAV"
    case aac = "AAC"
    case flac = "FLAC"
    
    // Video formats
    case mp4 = "MP4"
    case mov = "MOV"
    case avi = "AVI"
    case mkv = "MKV"
    
    // Image formats
    case jpg = "JPG"
    case png = "PNG"
    case gif = "GIF"
    case svg = "SVG"
    
    // Document formats
    case pdf = "PDF"
    case doc = "DOC"
    case txt = "TXT"
    
    var isAudio: Bool {
        return self == .mp3 || self == .wav || self == .aac || self == .flac
    }
    
    var isVideo: Bool {
        return self == .mp4 || self == .mov || self == .avi || self == .mkv
    }
    
    var isImage: Bool {
        return self == .jpg || self == .png || self == .gif || self == .svg
    }
    
    var isDocument: Bool {
        return self == .pdf || self == .doc || self == .txt
    }
}

// Local file class - This is an incompatible interface
class LocalFile {
    let filePath: String
    let fileName: String
    let fileExtension: String
    let fileFormat: FileFormat
    let fileSizeBytes: Int
    let creationDate: Date
    let modificationDate: Date
    let owner: String
    let permissions: String
    private(set) var isOpen: Bool = false
    
    init(
        filePath: String,
        fileName: String,
        fileExtension: String,
        fileFormat: FileFormat,
        fileSizeBytes: Int,
        creationDate: Date,
        modificationDate: Date,
        owner: String,
        permissions: String
    ) {
        self.filePath = filePath
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.fileFormat = fileFormat
        self.fileSizeBytes = fileSizeBytes
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.owner = owner
        self.permissions = permissions
    }
    
    // LocalFile-specific methods
    func openFile() -> Bool {
        if permissions.contains("r") {
            isOpen = true
            print("📂 Opened file '\(fileName).\(fileExtension)'")
            return true
        } else {
            print("⚠️ Permission denied: Cannot read file '\(fileName).\(fileExtension)'")
            return false
        }
    }
    
    func closeFile() {
        if isOpen {
            isOpen = false
            print("📂 Closed file '\(fileName).\(fileExtension)'")
        }
    }
    
    func getFileInfo() -> String {
        return """
        File: \(fileName).\(fileExtension)
        Path: \(filePath)
        Format: \(fileFormat.rawValue)
        Size: \(fileSizeBytes) bytes
        Created: \(creationDate)
        Modified: \(modificationDate)
        Owner: \(owner)
        Permissions: \(permissions)
        """
    }
    
    func getFullPath() -> String {
        return "\(filePath)/\(fileName).\(fileExtension)"
    }
    
    func getFileProperties() -> [String: Any] {
        return [
            "path": filePath,
            "name": fileName,
            "extension": fileExtension,
            "format": fileFormat.rawValue,
            "size": fileSizeBytes,
            "creation_date": creationDate,
            "modification_date": modificationDate,
            "owner": owner,
            "permissions": permissions,
            "is_open": isOpen
        ]
    }
}

// Local file system service
class LocalFileSystemService {
    private var files: [String: LocalFile] = [:]
    
    // Get file by path
    func getFile(path: String) -> LocalFile? {
        return files[path]
    }
    
    // List files by extension
    func listFiles(withExtension ext: String) -> [LocalFile] {
        return Array(files.values).filter { $0.fileExtension.lowercased() == ext.lowercased() }
    }
    
    // List files by format
    func listFiles(withFormat format: FileFormat) -> [LocalFile] {
        return Array(files.values).filter { $0.fileFormat == format }
    }
    
    // Search files by name
    func searchFiles(name: String) -> [LocalFile] {
        // If name is empty, return all files
        if name.isEmpty {
            return Array(files.values)
        }
        
        // Otherwise, filter files by name
        return Array(files.values).filter { 
            $0.fileName.lowercased().contains(name.lowercased())
        }
    }
    
    // Add a file to the system
    func addFile(_ file: LocalFile) {
        files[file.getFullPath()] = file
    }
    
    // Remove a file from the system
    func removeFile(path: String) -> Bool {
        if let file = files[path] {
            files.removeValue(forKey: path)
            print("🗑️ Removed file '\(file.fileName).\(file.fileExtension)'")
            return true
        } else {
            print("⚠️ File not found at path: \(path)")
            return false
        }
    }
    
    // Create some sample files
    func createSampleFiles() {
        // Audio files
        let audioFile1 = LocalFile(
            filePath: "/Users/user/Music",
            fileName: "favorite_song",
            fileExtension: "mp3",
            fileFormat: .mp3,
            fileSizeBytes: 4500000, // 4.5 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 100), // 100 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 50), // 50 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Video files
        let videoFile1 = LocalFile(
            filePath: "/Users/user/Videos",
            fileName: "vacation_highlights",
            fileExtension: "mp4",
            fileFormat: .mp4,
            fileSizeBytes: 250000000, // 250 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 60), // 60 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 60), // 60 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Image files
        let imageFile1 = LocalFile(
            filePath: "/Users/user/Pictures",
            fileName: "family_photo",
            fileExtension: "jpg",
            fileFormat: .jpg,
            fileSizeBytes: 2500000, // 2.5 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 200), // 200 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 200), // 200 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Document files
        let documentFile1 = LocalFile(
            filePath: "/Users/user/Documents",
            fileName: "important_notes",
            fileExtension: "pdf",
            fileFormat: .pdf,
            fileSizeBytes: 1200000, // 1.2 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 30), // 30 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 5), // 5 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Add another audio file
        let audioFile2 = LocalFile(
            filePath: "/Users/user/Music",
            fileName: "classical_collection",
            fileExtension: "flac",
            fileFormat: .flac,
            fileSizeBytes: 25000000, // 25 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 45), // 45 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 45), // 45 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Add another video file
        let videoFile2 = LocalFile(
            filePath: "/Users/user/Videos",
            fileName: "tutorial_recording",
            fileExtension: "mov",
            fileFormat: .mov,
            fileSizeBytes: 180000000, // 180 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 20), // 20 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 20), // 20 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Add a Swift-related document for search demo
        let swiftDocumentFile = LocalFile(
            filePath: "/Users/user/Documents/Programming",
            fileName: "swift_design_patterns",
            fileExtension: "pdf",
            fileFormat: .pdf,
            fileSizeBytes: 3500000, // 3.5 MB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 10), // 10 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 2), // 2 days ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Add a Swift code file
        let swiftCodeFile = LocalFile(
            filePath: "/Users/user/Documents/Programming/Projects",
            fileName: "MediaLibraryAdapter",
            fileExtension: "txt",
            fileFormat: .txt,
            fileSizeBytes: 15000, // 15 KB
            creationDate: Date().addingTimeInterval(-3600 * 24 * 3), // 3 days ago
            modificationDate: Date().addingTimeInterval(-3600 * 24 * 1), // 1 day ago
            owner: "user",
            permissions: "rw-r--r--"
        )
        
        // Add all files to the collection
        addFile(audioFile1)
        addFile(audioFile2)
        addFile(videoFile1)
        addFile(videoFile2)
        addFile(imageFile1)
        addFile(documentFile1)
        addFile(swiftDocumentFile)
        addFile(swiftCodeFile)
        
        print("✅ Created \(files.count) sample local files")
    }
}
