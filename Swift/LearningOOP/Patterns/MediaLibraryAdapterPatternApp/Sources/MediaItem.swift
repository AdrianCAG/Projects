// MediaItem.swift - Target interface for the Adapter Pattern

import Foundation

// Media type enum
enum MediaType {
    case audio
    case video
    case image
    case document
    case other
    
    var description: String {
        switch self {
        case .audio: return "Audio"
        case .video: return "Video"
        case .image: return "Image"
        case .document: return "Document"
        case .other: return "Other"
        }
    }
}

// Media quality enum
enum MediaQuality {
    case low
    case medium
    case high
    case ultra
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .ultra: return "Ultra"
        }
    }
}

// Target interface - This is what the client expects to work with
protocol MediaItem {
    var id: String { get }
    var title: String { get }
    var creator: String { get }
    var duration: TimeInterval? { get } // nil for non-time-based media
    var size: Int { get } // in bytes
    var type: MediaType { get }
    var tags: [String] { get }
    var dateAdded: Date { get }
    var lastAccessed: Date? { get set }
    var metadata: [String: String] { get }
    var sourceType: String { get } // e.g., "Spotify", "YouTube", "LocalFile"
    
    func play() -> Bool
    func stop()
    func getInfo() -> String
    func isCompatibleWith(device: String) -> Bool
}

// Extension to provide default implementations for some methods
extension MediaItem {
    func getInfo() -> String {
        var info = """
        Title: \(title)
        Creator: \(creator)
        Type: \(type.description)
        Source: \(sourceType)
        Tags: \(tags.joined(separator: ", "))
        Added: \(formatDate(dateAdded))
        """
        
        if let duration = duration {
            info += "\nDuration: \(formatDuration(duration))"
        }
        
        if let lastAccessed = lastAccessed {
            info += "\nLast Accessed: \(formatDate(lastAccessed))"
        }
        
        info += "\nSize: \(formatSize(size))"
        
        if !metadata.isEmpty {
            info += "\n\nMetadata:"
            for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
                info += "\n  \(key): \(value)"
            }
        }
        
        return info
    }
    
    func isCompatibleWith(device: String) -> Bool {
        // Default implementation assumes compatibility with all devices
        return true
    }
    
    // Helper methods for formatting
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func formatSize(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        
        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1.0 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(bytes) bytes"
        }
    }
}
