// SpotifyAdapter.swift - Adapter for Spotify tracks

import Foundation

// Object Adapter for Spotify tracks
class SpotifyTrackAdapter: MediaItem {
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
    let sourceType: String = "Spotify"
    
    // Reference to the adaptee
    private let spotifyTrack: SpotifyTrack
    private let spotifyService: SpotifyAPIService
    
    init(spotifyTrack: SpotifyTrack, spotifyService: SpotifyAPIService) {
        self.spotifyTrack = spotifyTrack
        self.spotifyService = spotifyService
        
        // Map Spotify track properties to MediaItem properties
        self.id = "spotify_" + spotifyTrack.trackId
        self.title = spotifyTrack.trackName
        self.creator = spotifyTrack.artistName
        self.duration = TimeInterval(spotifyTrack.durationMs) / 1000.0
        
        // Estimate size based on duration and quality
        let bitrate: Int
        switch spotifyTrack.quality {
        case .normal: bitrate = 128 // 128 kbps
        case .high: bitrate = 256 // 256 kbps
        case .premium: bitrate = 320 // 320 kbps
        }
        
        // Size in bytes = (bitrate in kbps * duration in seconds) / 8 * 1000
        self.size = Int((Double(bitrate) * (Double(spotifyTrack.durationMs) / 1000.0)) / 8.0 * 1000.0)
        
        self.type = .audio
        self.tags = spotifyTrack.genres
        self.dateAdded = spotifyTrack.addedAt
        
        // Create metadata from Spotify-specific properties
        var meta: [String: String] = [:]
        meta["album"] = spotifyTrack.albumName
        meta["popularity"] = String(spotifyTrack.popularity)
        meta["explicit"] = spotifyTrack.isExplicit ? "Yes" : "No"
        meta["quality"] = spotifyTrack.quality.rawValue
        if let previewUrl = spotifyTrack.previewUrl {
            meta["preview_url"] = previewUrl
        }
        self.metadata = meta
    }
    
    // Implement MediaItem methods
    func play() -> Bool {
        // Check if Spotify service is authenticated
        guard spotifyService.checkAuthentication() else {
            print("⚠️ Spotify service is not authenticated")
            return false
        }
        
        // Use the adaptee's method to play the track
        return spotifyTrack.startPlayback()
    }
    
    func stop() {
        spotifyTrack.pausePlayback()
    }
    
    func isCompatibleWith(device: String) -> Bool {
        // Check if the device is compatible with Spotify
        let compatibleDevices = ["iPhone", "iPad", "Android", "Desktop", "Web", "Smart Speaker"]
        return compatibleDevices.contains { device.lowercased().contains($0.lowercased()) }
    }
}
