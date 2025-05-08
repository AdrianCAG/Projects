// AdapterFactory.swift - Factory for creating adapters

import Foundation

// Factory for creating adapters
class AdapterFactory {
    private let spotifyService: SpotifyAPIService
    private let youtubeService: YouTubeAPIService
    private let fileSystemService: LocalFileSystemService
    
    init(
        spotifyService: SpotifyAPIService,
        youtubeService: YouTubeAPIService,
        fileSystemService: LocalFileSystemService
    ) {
        self.spotifyService = spotifyService
        self.youtubeService = youtubeService
        self.fileSystemService = fileSystemService
    }
    
    // Create an adapter for a Spotify track
    func createSpotifyAdapter(for trackId: String) -> MediaItem? {
        guard let track = spotifyService.getTrack(id: trackId) else {
            print("⚠️ Spotify track with ID '\(trackId)' not found")
            return nil
        }
        
        return SpotifyTrackAdapter(spotifyTrack: track, spotifyService: spotifyService)
    }
    
    // Create adapters for all Spotify tracks
    func createAllSpotifyAdapters() -> [MediaItem] {
        // Get all tracks from the service
        let tracks = spotifyService.searchTracks(query: "")
        
        // Create an adapter for each track
        var adapters: [MediaItem] = []
        for track in tracks {
            adapters.append(SpotifyTrackAdapter(spotifyTrack: track, spotifyService: spotifyService))
        }
        
        return adapters
    }
    
    // Create an adapter for a YouTube video
    func createYouTubeAdapter(for videoId: String) -> MediaItem? {
        guard let video = youtubeService.getVideo(id: videoId) else {
            print("⚠️ YouTube video with ID '\(videoId)' not found")
            return nil
        }
        
        return YouTubeVideoAdapter(youtubeVideo: video, youtubeService: youtubeService)
    }
    
    // Create adapters for all YouTube videos
    func createAllYouTubeAdapters() -> [MediaItem] {
        // Get all videos from the service
        let videos = youtubeService.searchVideos(query: "")
        
        // Create an adapter for each video
        var adapters: [MediaItem] = []
        for video in videos {
            adapters.append(YouTubeVideoAdapter(youtubeVideo: video, youtubeService: youtubeService))
        }
        
        return adapters
    }
    
    // Create an adapter for a local file
    func createLocalFileAdapter(for filePath: String) -> MediaItem? {
        guard let file = fileSystemService.getFile(path: filePath) else {
            print("⚠️ Local file at path '\(filePath)' not found")
            return nil
        }
        
        return LocalFileAdapter(localFile: file, fileSystemService: fileSystemService)
    }
    
    // Create adapters for all local files
    func createAllLocalFileAdapters() -> [MediaItem] {
        // Get all files from the service
        let files = fileSystemService.searchFiles(name: "")
        
        // Create an adapter for each file
        var adapters: [MediaItem] = []
        for file in files {
            adapters.append(LocalFileAdapter(localFile: file, fileSystemService: fileSystemService))
        }
        
        return adapters
    }
    
    // Create an adapter based on source type and ID
    func createAdapter(sourceType: String, id: String) -> MediaItem? {
        switch sourceType.lowercased() {
        case "spotify":
            return createSpotifyAdapter(for: id)
        case "youtube":
            return createYouTubeAdapter(for: id)
        case "localfile":
            return createLocalFileAdapter(for: id)
        default:
            print("⚠️ Unknown source type: \(sourceType)")
            return nil
        }
    }
    
    // Create adapters for all media from all sources
    func createAllAdapters() -> [MediaItem] {
        var adapters: [MediaItem] = []
        
        adapters.append(contentsOf: createAllSpotifyAdapters())
        adapters.append(contentsOf: createAllYouTubeAdapters())
        adapters.append(contentsOf: createAllLocalFileAdapters())
        
        return adapters
    }
}
