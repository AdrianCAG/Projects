// YouTubeAdapter.swift - Adapter for YouTube videos

import Foundation

// Object Adapter for YouTube videos
class YouTubeVideoAdapter: MediaItem {
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
    let sourceType: String = "YouTube"
    
    // Reference to the adaptee
    private let youtubeVideo: YouTubeVideo
    private let youtubeService: YouTubeAPIService
    private var selectedQuality: YouTubeQuality
    
    init(youtubeVideo: YouTubeVideo, youtubeService: YouTubeAPIService) {
        self.youtubeVideo = youtubeVideo
        self.youtubeService = youtubeService
        
        // Map YouTube video properties to MediaItem properties
        self.id = "youtube_" + youtubeVideo.videoId
        self.title = youtubeVideo.title
        self.creator = youtubeVideo.channelName
        self.duration = TimeInterval(youtubeVideo.lengthSeconds)
        self.type = .video
        self.tags = youtubeVideo.categories
        self.dateAdded = youtubeVideo.uploadDate
        
        // Select the highest available quality by default - must be done before using helper methods
        let sortedQualities = youtubeVideo.availableQualities.sorted { 
            // Manual comparison without calling the method
            let quality1Value: Int
            switch $0 {
            case .p144: quality1Value = 144
            case .p240: quality1Value = 240
            case .p360: quality1Value = 360
            case .p480: quality1Value = 480
            case .p720: quality1Value = 720
            case .p1080: quality1Value = 1080
            case .p1440: quality1Value = 1440
            case .p2160: quality1Value = 2160
            }
            
            let quality2Value: Int
            switch $1 {
            case .p144: quality2Value = 144
            case .p240: quality2Value = 240
            case .p360: quality2Value = 360
            case .p480: quality2Value = 480
            case .p720: quality2Value = 720
            case .p1080: quality2Value = 1080
            case .p1440: quality2Value = 1440
            case .p2160: quality2Value = 2160
            }
            
            return quality1Value > quality2Value
        }
        self.selectedQuality = sortedQualities.first ?? .p360
        
        // Estimate size based on duration and quality
        // This is a very rough estimate as actual size depends on video content
        let bitrateKbps: Int
        switch self.selectedQuality {
        case .p144: bitrateKbps = 100 // 100 Kbps
        case .p240: bitrateKbps = 300 // 300 Kbps
        case .p360: bitrateKbps = 500 // 500 Kbps
        case .p480: bitrateKbps = 1000 // 1 Mbps
        case .p720: bitrateKbps = 2500 // 2.5 Mbps
        case .p1080: bitrateKbps = 5000 // 5 Mbps
        case .p1440: bitrateKbps = 10000 // 10 Mbps
        case .p2160: bitrateKbps = 20000 // 20 Mbps
        }
        // Size in bytes = (bitrate in kbps * duration in seconds) / 8 * 1000
        self.size = Int((Double(bitrateKbps) * Double(youtubeVideo.lengthSeconds)) / 8.0 * 1000.0)
        
        // Create metadata from YouTube-specific properties
        var meta: [String: String] = [:]
        meta["views"] = String(youtubeVideo.viewCount)
        meta["likes"] = String(youtubeVideo.likeCount)
        meta["dislikes"] = String(youtubeVideo.dislikeCount)
        meta["description"] = youtubeVideo.description
        meta["thumbnail"] = youtubeVideo.thumbnailUrl
        meta["quality"] = selectedQuality.rawValue
        meta["age_restricted"] = youtubeVideo.isAgeRestricted ? "Yes" : "No"
        meta["available_qualities"] = youtubeVideo.availableQualities.map { $0.rawValue }.joined(separator: ", ")
        self.metadata = meta
    }
    
    // Implement MediaItem methods
    func play() -> Bool {
        // Check if YouTube service is authenticated
        guard youtubeService.checkAuthentication() else {
            print("⚠️ YouTube service is not authenticated")
            return false
        }
        
        // Use the adaptee's method to play the video
        return youtubeVideo.watchVideo(quality: selectedQuality)
    }
    
    func stop() {
        youtubeVideo.stopVideo()
    }
    
    func isCompatibleWith(device: String) -> Bool {
        // Check if the device is compatible with YouTube and the selected quality
        let compatibleDevices = ["iPhone", "iPad", "Android", "Desktop", "Web", "Smart TV"]
        
        // Check if device is compatible with YouTube
        let isDeviceCompatible = compatibleDevices.contains { device.lowercased().contains($0.lowercased()) }
        
        // For mobile devices, check if the quality is too high
        let isMobile = ["iPhone", "iPad", "Android"].contains { device.lowercased().contains($0.lowercased()) }
        let isQualityCompatible = !isMobile || qualityToInt(selectedQuality) <= qualityToInt(.p1080)
        
        return isDeviceCompatible && isQualityCompatible
    }
    
    // Helper method to set video quality
    func setQuality(_ quality: YouTubeQuality) -> Bool {
        if youtubeVideo.availableQualities.contains(quality) {
            selectedQuality = quality
            print("🎬 Set YouTube video quality to \(quality.rawValue)")
            return true
        } else {
            print("⚠️ Quality \(quality.rawValue) is not available for this video")
            return false
        }
    }
    
    // Helper method to convert quality to integer for comparison
    private func qualityToInt(_ quality: YouTubeQuality) -> Int {
        switch quality {
        case .p144: return 144
        case .p240: return 240
        case .p360: return 360
        case .p480: return 480
        case .p720: return 720
        case .p1080: return 1080
        case .p1440: return 1440
        case .p2160: return 2160
        }
    }
    
    // Helper method to estimate bitrate based on quality
    private func qualityToBitrate(_ quality: YouTubeQuality) -> Int {
        switch quality {
        case .p144: return 100 // 100 Kbps
        case .p240: return 300 // 300 Kbps
        case .p360: return 500 // 500 Kbps
        case .p480: return 1000 // 1 Mbps
        case .p720: return 2500 // 2.5 Mbps
        case .p1080: return 5000 // 5 Mbps
        case .p1440: return 10000 // 10 Mbps
        case .p2160: return 20000 // 20 Mbps
        }
    }
}
