// LocalFileAdapter.swift - Adapter for local files

import Foundation

// Object Adapter for local files
class LocalFileAdapter: MediaItem {
    // Properties from MediaItem interface
    let id: String
    let title: String
    let creator: String
    let duration: TimeInterval?
    let size: Int
    let type: MediaType
    let tags: [String]
    let dateAdded: Date
    var lastAccessed: Date?
    let metadata: [String: String]
    let sourceType: String = "LocalFile"
    
    // Reference to the adaptee
    private let localFile: LocalFile
    private let fileSystemService: LocalFileSystemService
    
    init(localFile: LocalFile, fileSystemService: LocalFileSystemService) {
        self.localFile = localFile
        self.fileSystemService = fileSystemService
        
        // Map LocalFile properties to MediaItem properties
        self.id = "local_" + localFile.getFullPath().replacingOccurrences(of: "/", with: "_")
        self.title = localFile.fileName
        self.creator = localFile.owner
        
        // Determine media type based on file format
        if localFile.fileFormat.isAudio {
            self.type = .audio
        } else if localFile.fileFormat.isVideo {
            self.type = .video
        } else if localFile.fileFormat.isImage {
            self.type = .image
        } else if localFile.fileFormat.isDocument {
            self.type = .document
        } else {
            self.type = .other
        }
        
        // Set size from file size
        self.size = localFile.fileSizeBytes
        
        // Use creation date as date added
        self.dateAdded = localFile.creationDate
        
        // Initialize other required properties before calling any methods
        // Extract tags manually instead of using the extractTags method
        let components = localFile.fileName.components(separatedBy: CharacterSet(charactersIn: "_ -.,()[]"))
        let potentialTags = components.filter { $0.count >= 3 }
        self.tags = Array(potentialTags.prefix(5))
        
        // Format dates manually for metadata
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        // Create metadata from LocalFile-specific properties
        var meta: [String: String] = [:]
        meta["path"] = localFile.filePath
        meta["extension"] = localFile.fileExtension
        meta["format"] = localFile.fileFormat.rawValue
        meta["permissions"] = localFile.permissions
        meta["creation_date"] = formatter.string(from: localFile.creationDate)
        meta["modification_date"] = formatter.string(from: localFile.modificationDate)
        self.metadata = meta
        
        // Set duration based on file format (only for audio/video) - after all properties are initialized
        if localFile.fileFormat.isAudio || localFile.fileFormat.isVideo {
            // Estimate duration based on file size and format using inline calculation
            let fileSizeMB = Double(localFile.fileSizeBytes) / (1024.0 * 1024.0)
            let estimatedDuration: TimeInterval
            
            switch localFile.fileFormat {
            case .mp3:
                // Rough estimate: 1 MB ≈ 1 minute of MP3 audio
                estimatedDuration = fileSizeMB * 60.0
            case .wav, .flac:
                // Uncompressed audio formats take more space
                // Rough estimate: 10 MB ≈ 1 minute of WAV/FLAC audio
                estimatedDuration = fileSizeMB * 6.0
            case .aac:
                // Rough estimate: 0.8 MB ≈ 1 minute of AAC audio
                estimatedDuration = fileSizeMB * 75.0
            case .mp4, .mov:
                // Rough estimate: 10 MB ≈ 1 minute of MP4/MOV video at medium quality
                estimatedDuration = fileSizeMB * 6.0
            case .avi, .mkv:
                // Rough estimate: 15 MB ≈ 1 minute of AVI/MKV video
                estimatedDuration = fileSizeMB * 4.0
            default:
                estimatedDuration = 0.0
            }
            
            self.duration = estimatedDuration
        } else {
            self.duration = nil
        }
        
        // Use modification date as last accessed
        self.lastAccessed = localFile.modificationDate
    }
    
    // Implement MediaItem methods
    func play() -> Bool {
        // Check if file is readable
        if !localFile.permissions.contains("r") {
            print("⚠️ Permission denied: Cannot read file '\(localFile.fileName).\(localFile.fileExtension)'")
            return false
        }
        
        // Check if file is playable
        if !(localFile.fileFormat.isAudio || localFile.fileFormat.isVideo || localFile.fileFormat.isImage) {
            print("⚠️ File format \(localFile.fileFormat.rawValue) is not playable")
            return false
        }
        
        // Open the file
        let success = localFile.openFile()
        if success {
            print("▶️ Playing local file '\(localFile.fileName).\(localFile.fileExtension)'")
        }
        return success
    }
    
    func stop() {
        if localFile.isOpen {
            localFile.closeFile()
        }
    }
    
    func isCompatibleWith(device: String) -> Bool {
        // Check if the device is compatible with the file format
        switch localFile.fileFormat {
        case .mp3, .aac:
            // Most devices support these audio formats
            return true
        case .wav, .flac:
            // Some mobile devices might not support these high-quality audio formats
            return !["iPhone", "iPad", "Android"].contains { device.lowercased().contains($0.lowercased()) }
        case .mp4:
            // Most devices support MP4
            return true
        case .mov:
            // Apple devices and most modern devices support MOV
            return ["iPhone", "iPad", "Mac", "Desktop"].contains { device.lowercased().contains($0.lowercased()) }
        case .avi, .mkv:
            // Some mobile devices might not support these video formats
            return !["iPhone", "iPad"].contains { device.lowercased().contains($0.lowercased()) }
        case .jpg, .png:
            // All devices support these image formats
            return true
        case .gif:
            // Most devices support GIF
            return true
        case .svg:
            // Some older devices might not support SVG
            return !["Old Phone", "Legacy"].contains { device.lowercased().contains($0.lowercased()) }
        case .pdf:
            // Most devices support PDF
            return true
        case .doc, .txt:
            // Most devices support these document formats
            return true
        }
    }
    
    // Helper method to estimate duration based on file size and format
    private func estimateDuration(_ file: LocalFile) -> TimeInterval {
        let fileSizeMB = Double(file.fileSizeBytes) / (1024.0 * 1024.0)
        
        switch file.fileFormat {
        case .mp3:
            // Rough estimate: 1 MB ≈ 1 minute of MP3 audio
            return fileSizeMB * 60.0
        case .wav, .flac:
            // Uncompressed audio formats take more space
            // Rough estimate: 10 MB ≈ 1 minute of WAV/FLAC audio
            return fileSizeMB * 6.0
        case .aac:
            // Rough estimate: 0.8 MB ≈ 1 minute of AAC audio
            return fileSizeMB * 75.0
        case .mp4, .mov:
            // Rough estimate: 10 MB ≈ 1 minute of MP4/MOV video at medium quality
            return fileSizeMB * 6.0
        case .avi, .mkv:
            // Rough estimate: 15 MB ≈ 1 minute of AVI/MKV video
            return fileSizeMB * 4.0
        default:
            return 0.0
        }
    }
    
    // Helper method to extract tags from file name
    private func extractTags(from fileName: String) -> [String] {
        // Split by common separators and extract potential tags
        let components = fileName.components(separatedBy: CharacterSet(charactersIn: "_ -.,()[]"))
        
        // Filter out empty components and components that are too short
        let potentialTags = components.filter { $0.count >= 3 }
        
        // Limit to a reasonable number of tags
        return Array(potentialTags.prefix(5))
    }
    
    // Helper method to format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
