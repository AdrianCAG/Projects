// YouTubeAPI.swift - Incompatible interface (Adaptee) for YouTube

import Foundation

// YouTube video quality enum
enum YouTubeQuality: String {
    case p144 = "144p"
    case p240 = "240p"
    case p360 = "360p"
    case p480 = "480p"
    case p720 = "720p"
    case p1080 = "1080p"
    case p1440 = "1440p"
    case p2160 = "2160p"
}

// YouTube video class - This is an incompatible interface
class YouTubeVideo {
    let videoId: String
    let title: String
    let channelName: String
    let lengthSeconds: Int
    let viewCount: Int
    let likeCount: Int
    let dislikeCount: Int
    let uploadDate: Date
    let description: String
    let categories: [String]
    let availableQualities: [YouTubeQuality]
    let thumbnailUrl: String
    let isAgeRestricted: Bool
    
    init(
        videoId: String,
        title: String,
        channelName: String,
        lengthSeconds: Int,
        viewCount: Int,
        likeCount: Int,
        dislikeCount: Int,
        uploadDate: Date,
        description: String,
        categories: [String],
        availableQualities: [YouTubeQuality],
        thumbnailUrl: String,
        isAgeRestricted: Bool
    ) {
        self.videoId = videoId
        self.title = title
        self.channelName = channelName
        self.lengthSeconds = lengthSeconds
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.uploadDate = uploadDate
        self.description = description
        self.categories = categories
        self.availableQualities = availableQualities
        self.thumbnailUrl = thumbnailUrl
        self.isAgeRestricted = isAgeRestricted
    }
    
    // YouTube-specific methods
    func watchVideo(quality: YouTubeQuality? = nil) -> Bool {
        if isAgeRestricted {
            print("⚠️ This video is age-restricted and requires verification")
            return false
        }
        
        let selectedQuality = quality ?? availableQualities.first ?? .p360
        if availableQualities.contains(selectedQuality) {
            print("📺 YouTube is playing '\(title)' at \(selectedQuality.rawValue)")
            return true
        } else {
            print("⚠️ Quality \(selectedQuality.rawValue) is not available for this video")
            print("📺 YouTube is playing '\(title)' at \(availableQualities.first?.rawValue ?? "default")")
            return true
        }
    }
    
    func stopVideo() {
        print("⏹️ YouTube stopped playing '\(title)'")
    }
    
    func getChannelInfo() -> String {
        return "Channel: \(channelName)"
    }
    
    func getVideoStats() -> String {
        return "Views: \(viewCount), Likes: \(likeCount), Dislikes: \(dislikeCount)"
    }
    
    func getVideoDetails() -> [String: Any] {
        return [
            "id": videoId,
            "title": title,
            "channel": channelName,
            "length_seconds": lengthSeconds,
            "view_count": viewCount,
            "like_count": likeCount,
            "dislike_count": dislikeCount,
            "upload_date": uploadDate,
            "description": description,
            "categories": categories,
            "available_qualities": availableQualities.map { $0.rawValue },
            "thumbnail_url": thumbnailUrl,
            "age_restricted": isAgeRestricted
        ]
    }
}

// YouTube API service
class YouTubeAPIService {
    private var isAuthenticated: Bool = false
    private var authToken: String?
    private var videos: [String: YouTubeVideo] = [:]
    
    // Authenticate with YouTube
    func authenticate(apiKey: String) -> Bool {
        // Simulate authentication
        print("🔐 Authenticating with YouTube...")
        isAuthenticated = true
        authToken = "youtube_mock_token_\(Int.random(in: 10000...99999))"
        print("✅ Authenticated with YouTube")
        return true
    }
    
    // Check if authenticated
    func checkAuthentication() -> Bool {
        return isAuthenticated
    }
    
    // Search for videos
    func searchVideos(query: String) -> [YouTubeVideo] {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with YouTube")
            return []
        }
        
        print("🔍 Searching YouTube for '\(query)'")
        // In a real app, this would call the YouTube API
        // For this demo, we'll return mock data
        
        // If query is empty, return all videos
        if query.isEmpty {
            return Array(videos.values)
        }
        
        // Otherwise, filter videos by title, channel, or description
        return Array(videos.values).filter { 
            $0.title.lowercased().contains(query.lowercased()) || 
            $0.channelName.lowercased().contains(query.lowercased()) ||
            $0.description.lowercased().contains(query.lowercased())
        }
    }
    
    // Get video by ID
    func getVideo(id: String) -> YouTubeVideo? {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with YouTube")
            return nil
        }
        
        return videos[id]
    }
    
    // Add a video to the local cache
    func addVideo(_ video: YouTubeVideo) {
        videos[video.videoId] = video
    }
    
    // Create some sample videos
    func createSampleVideos() {
        let video1 = YouTubeVideo(
            videoId: "youtube_1",
            title: "How to Code in Swift",
            channelName: "SwiftMaster",
            lengthSeconds: 1200, // 20 minutes
            viewCount: 250000,
            likeCount: 15000,
            dislikeCount: 300,
            uploadDate: Date().addingTimeInterval(-3600 * 24 * 60), // 60 days ago
            description: "Learn the basics of Swift programming in this comprehensive tutorial.",
            categories: ["Education", "Programming", "Technology"],
            availableQualities: [.p360, .p480, .p720, .p1080],
            thumbnailUrl: "https://youtube.thumbnail/how_to_code_swift",
            isAgeRestricted: false
        )
        
        let video2 = YouTubeVideo(
            videoId: "youtube_2",
            title: "Design Patterns Explained",
            channelName: "CodeGuru",
            lengthSeconds: 1800, // 30 minutes
            viewCount: 180000,
            likeCount: 12000,
            dislikeCount: 200,
            uploadDate: Date().addingTimeInterval(-3600 * 24 * 45), // 45 days ago
            description: "Understanding software design patterns and when to use them.",
            categories: ["Education", "Programming", "Technology"],
            availableQualities: [.p360, .p480, .p720, .p1080, .p1440],
            thumbnailUrl: "https://youtube.thumbnail/design_patterns",
            isAgeRestricted: false
        )
        
        let video3 = YouTubeVideo(
            videoId: "youtube_3",
            title: "Advanced iOS Development",
            channelName: "AppleDev",
            lengthSeconds: 2700, // 45 minutes
            viewCount: 120000,
            likeCount: 9000,
            dislikeCount: 150,
            uploadDate: Date().addingTimeInterval(-3600 * 24 * 30), // 30 days ago
            description: "Take your iOS development skills to the next level with these advanced techniques.",
            categories: ["Education", "Programming", "Technology"],
            availableQualities: [.p360, .p480, .p720, .p1080, .p1440, .p2160],
            thumbnailUrl: "https://youtube.thumbnail/advanced_ios",
            isAgeRestricted: false
        )
        
        // Add a music video
        let video4 = YouTubeVideo(
            videoId: "youtube_4",
            title: "Top 10 Music Hits of 2024",
            channelName: "MusicCharts",
            lengthSeconds: 900, // 15 minutes
            viewCount: 1500000,
            likeCount: 75000,
            dislikeCount: 2000,
            uploadDate: Date().addingTimeInterval(-3600 * 24 * 15), // 15 days ago
            description: "Counting down the top 10 music hits of 2024 so far.",
            categories: ["Music", "Entertainment"],
            availableQualities: [.p360, .p480, .p720, .p1080, .p1440],
            thumbnailUrl: "https://youtube.thumbnail/top_10_music",
            isAgeRestricted: false
        )
        
        // Add a Swift-specific video for search demo
        let video5 = YouTubeVideo(
            videoId: "youtube_5",
            title: "Swift Adapter Pattern Implementation",
            channelName: "SwiftPatterns",
            lengthSeconds: 1500, // 25 minutes
            viewCount: 85000,
            likeCount: 7500,
            dislikeCount: 120,
            uploadDate: Date().addingTimeInterval(-3600 * 24 * 7), // 7 days ago
            description: "Learn how to implement the Adapter design pattern in Swift to create a unified media library.",
            categories: ["Education", "Programming", "Swift"],
            availableQualities: [.p360, .p480, .p720, .p1080],
            thumbnailUrl: "https://youtube.thumbnail/swift_adapter_pattern",
            isAgeRestricted: false
        )
        
        // Store all videos in the collection
        addVideo(video1)
        addVideo(video2)
        addVideo(video3)
        addVideo(video4)
        addVideo(video5)
        
        print("✅ Created \(videos.count) sample YouTube videos")
    }
}
