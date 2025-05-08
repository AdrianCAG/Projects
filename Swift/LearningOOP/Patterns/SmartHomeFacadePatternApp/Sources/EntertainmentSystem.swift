// EntertainmentSystem.swift - Complex subsystem for home entertainment

import Foundation

// Media type enum
enum MediaType: String {
    case music = "Music"
    case movie = "Movie"
    case tv = "TV"
    case game = "Game"
    case photo = "Photo"
    case radio = "Radio"
}

// Media source enum
enum MediaSource: String {
    case streaming = "Streaming"
    case localMedia = "Local Media"
    case broadcast = "Broadcast"
    case bluetooth = "Bluetooth"
    case airplay = "AirPlay"
    case hdmi = "HDMI"
}

// Media content struct
struct MediaContent {
    let title: String
    let artist: String?
    let album: String?
    let duration: Int? // in seconds
    let type: MediaType
    let source: MediaSource
    
    var description: String {
        var desc = "\(title)"
        if let artist = artist {
            desc += " by \(artist)"
        }
        if let album = album {
            desc += " from \(album)"
        }
        if let duration = duration {
            let minutes = duration / 60
            let seconds = duration % 60
            desc += " (\(minutes):\(String(format: "%02d", seconds)))"
        }
        return desc
    }
}

// Media player protocol
protocol MediaPlayer {
    var id: String { get }
    var name: String { get }
    var isOn: Bool { get }
    var isPlaying: Bool { get }
    var volume: Int { get } // 0-100%
    var currentMedia: MediaContent? { get }
    var supportedMediaTypes: [MediaType] { get }
    var supportedSources: [MediaSource] { get }
    
    func turnOn()
    func turnOff()
    func play()
    func pause()
    func stop()
    func setVolume(_ level: Int)
    func playMedia(_ media: MediaContent) -> Bool
    func getStatus() -> String
}

// Basic media player implementation
class BasicMediaPlayer: MediaPlayer {
    let id: String
    let name: String
    private(set) var isOn: Bool = false
    private(set) var isPlaying: Bool = false
    private(set) var volume: Int = 50
    private(set) var currentMedia: MediaContent?
    let supportedMediaTypes: [MediaType]
    let supportedSources: [MediaSource]
    
    init(id: String, name: String, supportedTypes: [MediaType], supportedSources: [MediaSource]) {
        self.id = id
        self.name = name
        self.supportedMediaTypes = supportedTypes
        self.supportedSources = supportedSources
    }
    
    func turnOn() {
        isOn = true
        print("🎵 Media player '\(name)' turned ON")
    }
    
    func turnOff() {
        if isPlaying {
            stop()
        }
        isOn = false
        print("🎵 Media player '\(name)' turned OFF")
    }
    
    func play() {
        if !isOn {
            turnOn()
        }
        
        if let media = currentMedia {
            isPlaying = true
            print("▶️ Media player '\(name)' playing: \(media.description)")
        } else {
            print("⚠️ No media selected on player '\(name)'")
        }
    }
    
    func pause() {
        if isPlaying {
            isPlaying = false
            print("⏸️ Media player '\(name)' paused")
        }
    }
    
    func stop() {
        if isPlaying {
            isPlaying = false
            print("⏹️ Media player '\(name)' stopped")
        }
    }
    
    func setVolume(_ level: Int) {
        volume = min(100, max(0, level))
        print("🔊 Media player '\(name)' volume set to \(volume)%")
    }
    
    func playMedia(_ media: MediaContent) -> Bool {
        // Check if this player supports the media type and source
        guard supportedMediaTypes.contains(media.type) else {
            print("⚠️ Media player '\(name)' does not support \(media.type.rawValue) content")
            return false
        }
        
        guard supportedSources.contains(media.source) else {
            print("⚠️ Media player '\(name)' does not support \(media.source.rawValue) source")
            return false
        }
        
        if !isOn {
            turnOn()
        }
        
        currentMedia = media
        print("🎵 Media player '\(name)' loaded: \(media.description)")
        play()
        return true
    }
    
    func getStatus() -> String {
        var status = "Media Player: \(name) [\(id)] - Status: \(isOn ? "On" : "Off")"
        if isOn {
            status += ", Volume: \(volume)%"
            status += ", Playback: \(isPlaying ? "Playing" : "Stopped")"
            if let media = currentMedia {
                status += ", Media: \(media.description)"
            }
        }
        return status
    }
}

// Smart TV implementation
class SmartTV: MediaPlayer {
    let id: String
    let name: String
    private(set) var isOn: Bool = false
    private(set) var isPlaying: Bool = false
    private(set) var volume: Int = 50
    private(set) var currentMedia: MediaContent?
    private(set) var currentChannel: Int = 1
    private(set) var currentInput: String = "TV"
    let supportedMediaTypes: [MediaType] = [.tv, .movie, .music, .photo]
    let supportedSources: [MediaSource] = [.streaming, .broadcast, .hdmi, .airplay]
    private var installedApps: [String] = ["Netflix", "YouTube", "Prime Video", "Disney+"]
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func turnOn() {
        isOn = true
        print("📺 Smart TV '\(name)' turned ON")
    }
    
    func turnOff() {
        if isPlaying {
            stop()
        }
        isOn = false
        print("📺 Smart TV '\(name)' turned OFF")
    }
    
    func play() {
        if !isOn {
            turnOn()
        }
        
        if let media = currentMedia {
            isPlaying = true
            print("▶️ Smart TV '\(name)' playing: \(media.description)")
        } else if currentInput == "TV" {
            isPlaying = true
            print("📺 Smart TV '\(name)' playing channel \(currentChannel)")
        } else {
            print("⚠️ No media selected on TV '\(name)'")
        }
    }
    
    func pause() {
        if isPlaying && currentMedia != nil {
            isPlaying = false
            print("⏸️ Smart TV '\(name)' paused")
        } else if currentInput == "TV" {
            print("⚠️ Cannot pause live TV on '\(name)'")
        }
    }
    
    func stop() {
        if isPlaying {
            isPlaying = false
            print("⏹️ Smart TV '\(name)' stopped")
        }
    }
    
    func setVolume(_ level: Int) {
        volume = min(100, max(0, level))
        print("🔊 Smart TV '\(name)' volume set to \(volume)%")
    }
    
    func playMedia(_ media: MediaContent) -> Bool {
        // Check if this TV supports the media type and source
        guard supportedMediaTypes.contains(media.type) else {
            print("⚠️ Smart TV '\(name)' does not support \(media.type.rawValue) content")
            return false
        }
        
        guard supportedSources.contains(media.source) else {
            print("⚠️ Smart TV '\(name)' does not support \(media.source.rawValue) source")
            return false
        }
        
        if !isOn {
            turnOn()
        }
        
        // Set appropriate input based on source
        switch media.source {
        case .streaming:
            currentInput = "Smart TV"
        case .broadcast:
            currentInput = "TV"
        case .hdmi:
            currentInput = "HDMI"
        case .airplay:
            currentInput = "AirPlay"
        default:
            currentInput = "Unknown"
        }
        
        currentMedia = media
        print("📺 Smart TV '\(name)' loaded: \(media.description) via \(currentInput)")
        play()
        return true
    }
    
    func setChannel(_ channel: Int) {
        if !isOn {
            turnOn()
        }
        
        currentChannel = max(1, channel)
        currentInput = "TV"
        currentMedia = nil
        print("📺 Smart TV '\(name)' changed to channel \(currentChannel)")
        isPlaying = true
    }
    
    func setInput(_ input: String) {
        if !isOn {
            turnOn()
        }
        
        currentInput = input
        currentMedia = nil
        print("📺 Smart TV '\(name)' input set to \(input)")
    }
    
    func launchApp(_ appName: String) -> Bool {
        if !isOn {
            turnOn()
        }
        
        if installedApps.contains(appName) {
            currentInput = "Smart TV"
            print("📱 Smart TV '\(name)' launched app: \(appName)")
            return true
        } else {
            print("⚠️ App '\(appName)' is not installed on TV '\(name)'")
            return false
        }
    }
    
    func installApp(_ appName: String) {
        if !installedApps.contains(appName) {
            installedApps.append(appName)
            print("📱 Installed app '\(appName)' on TV '\(name)'")
        } else {
            print("⚠️ App '\(appName)' is already installed on TV '\(name)'")
        }
    }
    
    func getStatus() -> String {
        var status = "Smart TV: \(name) [\(id)] - Status: \(isOn ? "On" : "Off")"
        if isOn {
            status += ", Volume: \(volume)%"
            status += ", Input: \(currentInput)"
            if currentInput == "TV" {
                status += ", Channel: \(currentChannel)"
            }
            status += ", Playback: \(isPlaying ? "Playing" : "Stopped")"
            if let media = currentMedia {
                status += ", Media: \(media.description)"
            }
        }
        return status
    }
}

// Sound system implementation
class SoundSystem: MediaPlayer {
    let id: String
    let name: String
    private(set) var isOn: Bool = false
    private(set) var isPlaying: Bool = false
    private(set) var volume: Int = 50
    private(set) var currentMedia: MediaContent?
    let supportedMediaTypes: [MediaType] = [.music, .movie, .tv, .radio]
    let supportedSources: [MediaSource] = [.streaming, .localMedia, .bluetooth, .airplay, .hdmi]
    private(set) var surroundMode: Bool = false
    private(set) var equalizer: [String: Int] = ["Bass": 0, "Mid": 0, "Treble": 0]
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func turnOn() {
        isOn = true
        print("🔊 Sound system '\(name)' turned ON")
    }
    
    func turnOff() {
        if isPlaying {
            stop()
        }
        isOn = false
        print("🔊 Sound system '\(name)' turned OFF")
    }
    
    func play() {
        if !isOn {
            turnOn()
        }
        
        if let media = currentMedia {
            isPlaying = true
            print("▶️ Sound system '\(name)' playing: \(media.description)")
        } else {
            print("⚠️ No media selected on sound system '\(name)'")
        }
    }
    
    func pause() {
        if isPlaying {
            isPlaying = false
            print("⏸️ Sound system '\(name)' paused")
        }
    }
    
    func stop() {
        if isPlaying {
            isPlaying = false
            print("⏹️ Sound system '\(name)' stopped")
        }
    }
    
    func setVolume(_ level: Int) {
        volume = min(100, max(0, level))
        print("🔊 Sound system '\(name)' volume set to \(volume)%")
    }
    
    func playMedia(_ media: MediaContent) -> Bool {
        // Check if this sound system supports the media type and source
        guard supportedMediaTypes.contains(media.type) else {
            print("⚠️ Sound system '\(name)' does not support \(media.type.rawValue) content")
            return false
        }
        
        guard supportedSources.contains(media.source) else {
            print("⚠️ Sound system '\(name)' does not support \(media.source.rawValue) source")
            return false
        }
        
        if !isOn {
            turnOn()
        }
        
        currentMedia = media
        print("🔊 Sound system '\(name)' loaded: \(media.description)")
        play()
        return true
    }
    
    func setSurroundMode(_ enabled: Bool) {
        surroundMode = enabled
        print("🔊 Sound system '\(name)' surround mode \(enabled ? "enabled" : "disabled")")
    }
    
    func setEqualizer(bass: Int, mid: Int, treble: Int) {
        equalizer["Bass"] = min(10, max(-10, bass))
        equalizer["Mid"] = min(10, max(-10, mid))
        equalizer["Treble"] = min(10, max(-10, treble))
        print("🔊 Sound system '\(name)' equalizer set to Bass: \(equalizer["Bass"]!), Mid: \(equalizer["Mid"]!), Treble: \(equalizer["Treble"]!)")
    }
    
    func getStatus() -> String {
        var status = "Sound System: \(name) [\(id)] - Status: \(isOn ? "On" : "Off")"
        if isOn {
            status += ", Volume: \(volume)%"
            status += ", Surround: \(surroundMode ? "On" : "Off")"
            status += ", EQ: Bass \(equalizer["Bass"]!), Mid \(equalizer["Mid"]!), Treble \(equalizer["Treble"]!)"
            status += ", Playback: \(isPlaying ? "Playing" : "Stopped")"
            if let media = currentMedia {
                status += ", Media: \(media.description)"
            }
        }
        return status
    }
}

// Media zone for grouping media players
class MediaZone {
    let id: String
    let name: String
    private var players: [MediaPlayer]
    
    init(id: String, name: String, players: [MediaPlayer] = []) {
        self.id = id
        self.name = name
        self.players = players
    }
    
    func addPlayer(_ player: MediaPlayer) {
        players.append(player)
    }
    
    func removePlayer(withId id: String) {
        players.removeAll { $0.id == id }
    }
    
    func turnAllOn() {
        print("🎵 Turning ON all media players in zone '\(name)'")
        for player in players {
            player.turnOn()
        }
    }
    
    func turnAllOff() {
        print("🎵 Turning OFF all media players in zone '\(name)'")
        for player in players {
            player.turnOff()
        }
    }
    
    func playAllSameMedia(_ media: MediaContent) {
        print("🎵 Playing media on all compatible players in zone '\(name)'")
        for player in players {
            _ = player.playMedia(media)
        }
    }
    
    func setAllVolumes(_ level: Int) {
        print("🔊 Setting volume to \(level)% for all players in zone '\(name)'")
        for player in players {
            player.setVolume(level)
        }
    }
    
    func getStatus() -> String {
        var status = "Media Zone: \(name) [\(id)] - \(players.count) players\n"
        for player in players {
            status += "  - \(player.getStatus())\n"
        }
        return status
    }
}

// Entertainment system that manages all media players and zones
class EntertainmentSystem {
    private var players: [String: MediaPlayer] = [:]
    private var zones: [String: MediaZone] = [:]
    private var mediaLibrary: [MediaContent] = []
    
    // Add a media player to the system
    func addPlayer(_ player: MediaPlayer) {
        players[player.id] = player
        print("➕ Added media player '\(player.name)' to the system")
    }
    
    // Remove a media player from the system
    func removePlayer(withId id: String) {
        if let player = players[id] {
            players.removeValue(forKey: id)
            print("➖ Removed media player '\(player.name)' from the system")
            
            // Also remove from any zones
            for (_, zone) in zones {
                zone.removePlayer(withId: id)
            }
        }
    }
    
    // Get a media player by ID
    func getPlayer(withId id: String) -> MediaPlayer? {
        return players[id]
    }
    
    // Add a media zone to the system
    func addZone(_ zone: MediaZone) {
        zones[zone.id] = zone
        print("➕ Added media zone '\(zone.name)' to the system")
    }
    
    // Remove a media zone from the system
    func removeZone(withId id: String) {
        if let zone = zones[id] {
            zones.removeValue(forKey: id)
            print("➖ Removed media zone '\(zone.name)' from the system")
        }
    }
    
    // Get a media zone by ID
    func getZone(withId id: String) -> MediaZone? {
        return zones[id]
    }
    
    // Add media content to the library
    func addToLibrary(_ media: MediaContent) {
        mediaLibrary.append(media)
        print("➕ Added '\(media.description)' to the media library")
    }
    
    // Find media in the library
    func findMedia(title: String) -> [MediaContent] {
        return mediaLibrary.filter { $0.title.lowercased().contains(title.lowercased()) }
    }
    
    // Turn on all media players in the system
    func turnAllPlayersOn() {
        print("🎵 Turning ON all media players in the system")
        for (_, player) in players {
            player.turnOn()
        }
    }
    
    // Turn off all media players in the system
    func turnAllPlayersOff() {
        print("🎵 Turning OFF all media players in the system")
        for (_, player) in players {
            player.turnOff()
        }
    }
    
    // Play the same media on all compatible players
    func playOnAllCompatiblePlayers(_ media: MediaContent) {
        print("🎵 Playing '\(media.description)' on all compatible players")
        for (_, player) in players {
            if player.supportedMediaTypes.contains(media.type) && player.supportedSources.contains(media.source) {
                _ = player.playMedia(media)
            }
        }
    }
    
    // Get status of all media players
    func getSystemStatus() -> String {
        var status = "=== Entertainment System Status ===\n"
        status += "Total Players: \(players.count)\n"
        status += "Total Zones: \(zones.count)\n"
        status += "Media Library: \(mediaLibrary.count) items\n\n"
        
        status += "Individual Players:\n"
        for (_, player) in players {
            status += "  - \(player.getStatus())\n"
        }
        
        status += "\nMedia Zones:\n"
        for (_, zone) in zones {
            status += "  - Zone: \(zone.name) [\(zone.id)]\n"
        }
        
        return status
    }
    
    // Create a scene with predefined player settings
    func createScene(name: String, settings: [(playerId: String, volume: Int, media: MediaContent?)]) -> Bool {
        print("🎬 Creating entertainment scene '\(name)'")
        
        for setting in settings {
            if let player = getPlayer(withId: setting.playerId) {
                player.turnOn()
                player.setVolume(setting.volume)
                if let media = setting.media {
                    _ = player.playMedia(media)
                }
            } else {
                print("⚠️ Player with ID '\(setting.playerId)' not found")
                return false
            }
        }
        
        return true
    }
    
    // Initialize with some default players, zones, and media
    func setupDefaultConfiguration() {
        // Create media players
        let livingRoomTV = SmartTV(id: "E001", name: "Living Room TV")
        let bedroomTV = SmartTV(id: "E002", name: "Bedroom TV")
        let mainSoundSystem = SoundSystem(id: "E003", name: "Main Sound System")
        let kitchenSpeaker = BasicMediaPlayer(
            id: "E004",
            name: "Kitchen Speaker",
            supportedTypes: [.music, .radio],
            supportedSources: [.bluetooth, .airplay, .streaming]
        )
        
        // Add all players to the system
        addPlayer(livingRoomTV)
        addPlayer(bedroomTV)
        addPlayer(mainSoundSystem)
        addPlayer(kitchenSpeaker)
        
        // Create zones
        let livingRoomZone = MediaZone(id: "Z001", name: "Living Room")
        livingRoomZone.addPlayer(livingRoomTV)
        livingRoomZone.addPlayer(mainSoundSystem)
        
        let bedroomZone = MediaZone(id: "Z002", name: "Bedroom")
        bedroomZone.addPlayer(bedroomTV)
        
        let kitchenZone = MediaZone(id: "Z003", name: "Kitchen")
        kitchenZone.addPlayer(kitchenSpeaker)
        
        // Add zones to the system
        addZone(livingRoomZone)
        addZone(bedroomZone)
        addZone(kitchenZone)
        
        // Add some sample media content
        let movie1 = MediaContent(
            title: "The Matrix",
            artist: nil,
            album: nil,
            duration: 8160, // 2h16m
            type: .movie,
            source: .streaming
        )
        
        let movie2 = MediaContent(
            title: "Inception",
            artist: nil,
            album: nil,
            duration: 8880, // 2h28m
            type: .movie,
            source: .streaming
        )
        
        let song1 = MediaContent(
            title: "Bohemian Rhapsody",
            artist: "Queen",
            album: "A Night at the Opera",
            duration: 354, // 5m54s
            type: .music,
            source: .streaming
        )
        
        let song2 = MediaContent(
            title: "Hotel California",
            artist: "Eagles",
            album: "Hotel California",
            duration: 390, // 6m30s
            type: .music,
            source: .streaming
        )
        
        // Add media to library
        addToLibrary(movie1)
        addToLibrary(movie2)
        addToLibrary(song1)
        addToLibrary(song2)
        
        print("✅ Default entertainment configuration set up successfully")
    }
}
