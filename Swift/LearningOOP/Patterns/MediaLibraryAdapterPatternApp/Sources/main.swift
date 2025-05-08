// MediaLibraryAdapterPatternApp - Demonstrates the Adapter Design Pattern
// A medium-high complexity implementation for a unified media library system

import Foundation

print("===== Media Library Adapter Pattern Demo =====\n")

// Initialize the services (adaptees)
print("Initializing media services...")
let spotifyService = SpotifyAPIService()
let youtubeService = YouTubeAPIService()
let fileSystemService = LocalFileSystemService()

// Authenticate with the services
spotifyService.authenticate(clientId: "demo_client_id", clientSecret: "demo_client_secret")
youtubeService.authenticate(apiKey: "demo_api_key")

// Create sample data in each service
spotifyService.createSampleTracks()
youtubeService.createSampleVideos()
fileSystemService.createSampleFiles()

// Create the adapter factory
let adapterFactory = AdapterFactory(
    spotifyService: spotifyService,
    youtubeService: youtubeService,
    fileSystemService: fileSystemService
)

// Create the media library (client)
let mediaLibrary = MediaLibrary()

print("\n=== Demonstrating the Adapter Pattern ===\n")
print("The Adapter Pattern allows objects with incompatible interfaces to collaborate.")
print("In this example, we have three different media sources with incompatible interfaces:")
print("1. Spotify API - For music streaming")
print("2. YouTube API - For video content")
print("3. Local File System - For files stored locally")
print("\nThe adapter pattern allows us to use these different sources through a unified MediaItem interface.")

// Add media items from different sources to the library
print("\n=== Adding Media Items from Different Sources ===\n")

// Add Spotify tracks
print("\n--- Adding Spotify Tracks ---")
let spotifyAdapters = adapterFactory.createAllSpotifyAdapters()
print("Found \(spotifyAdapters.count) Spotify tracks")
for adapter in spotifyAdapters {
    mediaLibrary.addItem(adapter)
}

// Add YouTube videos
print("\n--- Adding YouTube Videos ---")
let youtubeAdapters = adapterFactory.createAllYouTubeAdapters()
print("Found \(youtubeAdapters.count) YouTube videos")
for adapter in youtubeAdapters {
    mediaLibrary.addItem(adapter)
}

// Add local files
print("\n--- Adding Local Files ---")
let localFileAdapters = adapterFactory.createAllLocalFileAdapters()
print("Found \(localFileAdapters.count) local files")
for adapter in localFileAdapters {
    mediaLibrary.addItem(adapter)
}

// Create playlists with mixed media types
print("\n=== Creating Mixed-Source Playlists ===\n")

// Create a music playlist with both Spotify and local audio files
mediaLibrary.createPlaylist(name: "My Music")
for item in mediaLibrary.getAllItems() where item.type == .audio {
    mediaLibrary.addItemToPlaylist(itemId: item.id, playlistName: "My Music")
}

// Create a video playlist with both YouTube and local video files
mediaLibrary.createPlaylist(name: "My Videos")
for item in mediaLibrary.getAllItems() where item.type == .video {
    mediaLibrary.addItemToPlaylist(itemId: item.id, playlistName: "My Videos")
}

// Display library statistics
print("\n=== Media Library Statistics ===\n")
print(mediaLibrary.getStatistics())

// Demonstrate playing items from different sources
print("\n=== Playing Media from Different Sources ===\n")

// Play a Spotify track
if let spotifyItem = spotifyAdapters.first {
    print("\n--- Playing a Spotify Track ---")
    print("Item Info:\n\(spotifyItem.getInfo())\n")
    mediaLibrary.playItem(withId: spotifyItem.id)
    mediaLibrary.stopItem(withId: spotifyItem.id)
}

// Play a YouTube video
if let youtubeItem = youtubeAdapters.first {
    print("\n--- Playing a YouTube Video ---")
    print("Item Info:\n\(youtubeItem.getInfo())\n")
    mediaLibrary.playItem(withId: youtubeItem.id)
    mediaLibrary.stopItem(withId: youtubeItem.id)
}

// Play a local file
if let localFileItem = localFileAdapters.first(where: { $0.type == .audio || $0.type == .video }) {
    print("\n--- Playing a Local File ---")
    print("Item Info:\n\(localFileItem.getInfo())\n")
    mediaLibrary.playItem(withId: localFileItem.id)
    mediaLibrary.stopItem(withId: localFileItem.id)
}

// Demonstrate searching across all sources
print("\n=== Searching Across All Sources ===\n")
let searchResults = mediaLibrary.searchItems(query: "swift")
print("Found \(searchResults.count) items matching 'swift'")
for (index, item) in searchResults.enumerated() {
    print("\n--- Result \(index + 1) ---")
    print("Title: \(item.title)")
    print("Creator: \(item.creator)")
    print("Type: \(item.type.description)")
    print("Source: \(item.sourceType)")
}

// Demonstrate filtering by type
print("\n=== Filtering by Media Type ===\n")
let audioItems = mediaLibrary.filterByType(.audio)
print("Found \(audioItems.count) audio items")

let videoItems = mediaLibrary.filterByType(.video)
print("Found \(videoItems.count) video items")

// Demonstrate compatibility checking
print("\n=== Checking Device Compatibility ===\n")
let allItems = mediaLibrary.getAllItems()
let devices = ["iPhone", "Desktop", "Smart TV"]

for device in devices {
    print("\nChecking compatibility with \(device):")
    var compatibleCount = 0
    
    for item in allItems {
        if item.isCompatibleWith(device: device) {
            compatibleCount += 1
        }
    }
    
    print("\(compatibleCount)/\(allItems.count) items are compatible with \(device)")
}

print("\n===== End of Adapter Pattern Demo =====\n")
print("This application demonstrates how the Adapter Pattern allows incompatible interfaces")
print("to work together through a unified interface. This enables the client code to work")
print("with different types of objects without knowing their specific implementation details.")
