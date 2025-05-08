// SpotifyAPI.swift - Incompatible interface (Adaptee) for Spotify

import Foundation

// Spotify track quality enum
enum SpotifyQuality: String {
    case normal = "Normal"
    case high = "High"
    case premium = "Premium"
}

// Spotify track class - This is an incompatible interface
class SpotifyTrack {
    let trackId: String
    let trackName: String
    let artistName: String
    let albumName: String
    let durationMs: Int
    let popularity: Int // 0-100
    let isExplicit: Bool
    let previewUrl: String?
    let quality: SpotifyQuality
    let addedAt: Date
    let genres: [String]
    let isPlayable: Bool
    
    init(
        trackId: String,
        trackName: String,
        artistName: String,
        albumName: String,
        durationMs: Int,
        popularity: Int,
        isExplicit: Bool,
        previewUrl: String?,
        quality: SpotifyQuality,
        addedAt: Date,
        genres: [String],
        isPlayable: Bool
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.albumName = albumName
        self.durationMs = durationMs
        self.popularity = popularity
        self.isExplicit = isExplicit
        self.previewUrl = previewUrl
        self.quality = quality
        self.addedAt = addedAt
        self.genres = genres
        self.isPlayable = isPlayable
    }
    
    // Spotify-specific methods
    func startPlayback() -> Bool {
        if isPlayable {
            print("🎵 Spotify is playing '\(trackName)' by \(artistName)")
            return true
        } else {
            print("⚠️ This track is not available for playback")
            return false
        }
    }
    
    func pausePlayback() {
        print("⏸️ Spotify paused '\(trackName)'")
    }
    
    func getArtistInfo() -> String {
        return "Artist: \(artistName)\nGenres: \(genres.joined(separator: ", "))"
    }
    
    func getAlbumInfo() -> String {
        return "Album: \(albumName)"
    }
    
    func getTrackDetails() -> [String: Any] {
        return [
            "id": trackId,
            "name": trackName,
            "artist": artistName,
            "album": albumName,
            "duration_ms": durationMs,
            "popularity": popularity,
            "explicit": isExplicit,
            "preview_url": previewUrl as Any,
            "quality": quality.rawValue,
            "added_at": addedAt,
            "genres": genres,
            "playable": isPlayable
        ]
    }
}

// Spotify API service
class SpotifyAPIService {
    private var isAuthenticated: Bool = false
    private var authToken: String?
    private var tracks: [String: SpotifyTrack] = [:]
    
    // Authenticate with Spotify
    func authenticate(clientId: String, clientSecret: String) -> Bool {
        // Simulate authentication
        print("🔐 Authenticating with Spotify...")
        isAuthenticated = true
        authToken = "spotify_mock_token_\(Int.random(in: 10000...99999))"
        print("✅ Authenticated with Spotify")
        return true
    }
    
    // Check if authenticated
    func checkAuthentication() -> Bool {
        return isAuthenticated
    }
    
    // Search for tracks
    func searchTracks(query: String) -> [SpotifyTrack] {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with Spotify")
            return []
        }
        
        print("🔍 Searching Spotify for '\(query)'")
        // In a real app, this would call the Spotify API
        // For this demo, we'll return mock data
        
        // If query is empty, return all tracks
        if query.isEmpty {
            return Array(tracks.values)
        }
        
        // Otherwise, filter tracks by name or artist
        return Array(tracks.values).filter { 
            $0.trackName.lowercased().contains(query.lowercased()) || 
            $0.artistName.lowercased().contains(query.lowercased()) 
        }
    }
    
    // Get track by ID
    func getTrack(id: String) -> SpotifyTrack? {
        guard isAuthenticated else {
            print("⚠️ Not authenticated with Spotify")
            return nil
        }
        
        return tracks[id]
    }
    
    // Add a track to the local cache
    func addTrack(_ track: SpotifyTrack) {
        tracks[track.trackId] = track
    }
    
    // Create some sample tracks
    func createSampleTracks() {
        // Create a variety of sample tracks
        let track1 = SpotifyTrack(
            trackId: "spotify_1",
            trackName: "Shape of You",
            artistName: "Ed Sheeran",
            albumName: "÷ (Divide)",
            durationMs: 233713,
            popularity: 98,
            isExplicit: false,
            previewUrl: "https://p.scdn.co/mp3-preview/shape-of-you.mp3",
            quality: .premium,
            addedAt: Date(timeIntervalSince1970: 1484265600), // Jan 13, 2017
            genres: ["pop", "dance pop"],
            isPlayable: true
        )
        
        let track2 = SpotifyTrack(
            trackId: "spotify_2",
            trackName: "Bohemian Rhapsody",
            artistName: "Queen",
            albumName: "A Night at the Opera",
            durationMs: 354320,
            popularity: 95,
            isExplicit: false,
            previewUrl: "https://p.scdn.co/mp3-preview/bohemian-rhapsody.mp3",
            quality: .premium,
            addedAt: Date().addingTimeInterval(-3600 * 24 * 30), // 30 days ago
            genres: ["rock", "classic rock"],
            isPlayable: true
        )
        
        let track3 = SpotifyTrack(
            trackId: "spotify_3",
            trackName: "Billie Jean",
            artistName: "Michael Jackson",
            albumName: "Thriller",
            durationMs: 294000, // 4:54
            popularity: 92,
            isExplicit: false,
            previewUrl: "https://spotify.preview/billie_jean",
            quality: .premium,
            addedAt: Date().addingTimeInterval(-3600 * 24 * 15), // 15 days ago
            genres: ["pop", "dance"],
            isPlayable: true
        )
        
        let track4 = SpotifyTrack(
            trackId: "spotify_4",
            trackName: "Hotel California",
            artistName: "Eagles",
            albumName: "Hotel California",
            durationMs: 390000, // 6:30
            popularity: 90,
            isExplicit: false,
            previewUrl: "https://spotify.preview/hotel_california",
            quality: .high,
            addedAt: Date().addingTimeInterval(-3600 * 24 * 10), // 10 days ago
            genres: ["Rock", "Classic Rock"],
            isPlayable: true
        )
        
        // Add a Swift programming related track for search demo
        let track5 = SpotifyTrack(
            trackId: "spotify_5",
            trackName: "Swift Programming Beats",
            artistName: "Code Tunes",
            albumName: "Programming Music Vol. 1",
            durationMs: 245000, // 4:05
            popularity: 75,
            isExplicit: false,
            previewUrl: "https://spotify.preview/swift_programming_beats",
            quality: .high,
            addedAt: Date().addingTimeInterval(-3600 * 24 * 5), // 5 days ago
            genres: ["instrumental", "programming"],
            isPlayable: true
        )
        
        // Add all tracks to the collection
        addTrack(track1)
        addTrack(track2)
        addTrack(track3)
        addTrack(track4)
        addTrack(track5)
        
        print("✅ Created \(tracks.count) sample Spotify tracks")
    }
}
