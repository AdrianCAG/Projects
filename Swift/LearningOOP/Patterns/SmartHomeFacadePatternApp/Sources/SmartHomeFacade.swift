// SmartHomeFacade.swift - Facade for the smart home system

import Foundation

// Predefined scenes for the smart home
enum HomeScene: String {
    case morning = "Morning"
    case day = "Day"
    case evening = "Evening"
    case night = "Night"
    case away = "Away"
    case vacation = "Vacation"
    case movie = "Movie Night"
    case party = "Party"
    case dinner = "Dinner"
    case reading = "Reading"
}

// The Facade class that simplifies interaction with all subsystems
class SmartHomeFacade {
    // Subsystems
    private let lightingSystem: LightingSystem
    private let securitySystem: SecuritySystem
    private let climateSystem: ClimateSystem
    private let entertainmentSystem: EntertainmentSystem
    
    // Home state
    private var isHomeOccupied: Bool = true
    private var currentScene: HomeScene?
    
    // Initialize the facade with all subsystems
    init() {
        // Create all subsystems
        lightingSystem = LightingSystem()
        securitySystem = SecuritySystem()
        climateSystem = ClimateSystem()
        entertainmentSystem = EntertainmentSystem()
        
        // Set up default configurations for each subsystem
        setupDefaultConfigurations()
    }
    
    // Set up default configurations for all subsystems
    private func setupDefaultConfigurations() {
        lightingSystem.setupDefaultConfiguration()
        securitySystem.setupDefaultConfiguration()
        climateSystem.setupDefaultConfiguration()
        entertainmentSystem.setupDefaultConfiguration()
    }
    
    // MARK: - Simplified Interface Methods
    
    // Set a home scene that coordinates all systems
    func setScene(_ scene: HomeScene) {
        print("\n🏠 Setting home scene: \(scene.rawValue)\n")
        
        currentScene = scene
        
        switch scene {
        case .morning:
            // Lighting: Bright, warm lights
            if let livingRoomGroup = lightingSystem.getGroup(withId: "G001") {
                livingRoomGroup.turnAllOn()
                livingRoomGroup.setAllBrightness(80)
                livingRoomGroup.setAllColor(RGBColor(red: 255, green: 200, blue: 150)) // Warm white
            }
            
            if let kitchenGroup = lightingSystem.getGroup(withId: "G002") {
                kitchenGroup.turnAllOn()
                kitchenGroup.setAllBrightness(100)
            }
            
            // Climate: Comfortable morning temperature
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.turnAllOn()
                mainFloorZone.setAllTargetTemperatures(21.5) // 21.5°C
                mainFloorZone.setAllModes(.heat)
            }
            
            // Security: Disarm
            securitySystem.disarm()
            
            // Entertainment: Morning news or music
            if let kitchenSpeaker = entertainmentSystem.getPlayer(withId: "E004") {
                kitchenSpeaker.turnOn()
                kitchenSpeaker.setVolume(40)
                
                // Find some morning music
                let morningMusic = MediaContent(
                    title: "Morning Playlist",
                    artist: nil,
                    album: nil,
                    duration: nil,
                    type: .music,
                    source: .streaming
                )
                
                _ = kitchenSpeaker.playMedia(morningMusic)
            }
            
        case .day:
            // Lighting: Bright natural light
            lightingSystem.turnAllLightsOff() // Assume natural daylight
            
            // Climate: Energy efficient daytime settings
            climateSystem.setEcoMode(true)
            
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(22.0) // 22°C
                mainFloorZone.setAllModes(.auto)
            }
            
            // Security: Disarm
            securitySystem.disarm()
            
            // Entertainment: Off or background
            entertainmentSystem.turnAllPlayersOff()
            
        case .evening:
            // Lighting: Warm, medium brightness
            if let livingRoomGroup = lightingSystem.getGroup(withId: "G001") {
                livingRoomGroup.turnAllOn()
                livingRoomGroup.setAllBrightness(60)
                livingRoomGroup.setAllColor(RGBColor(red: 255, green: 180, blue: 120)) // Warmer
            }
            
            if let kitchenGroup = lightingSystem.getGroup(withId: "G002") {
                kitchenGroup.turnAllOn()
                kitchenGroup.setAllBrightness(70)
            }
            
            // Climate: Comfortable evening temperature
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(21.0) // 21°C
            }
            
            // Security: Perimeter only
            securitySystem.armStay()
            
            // Entertainment: Ready for evening entertainment
            if let livingRoomZone = entertainmentSystem.getZone(withId: "Z001") {
                livingRoomZone.turnAllOn()
            }
            
        case .night:
            // Lighting: Dim or off
            lightingSystem.turnAllLightsOff()
            
            // Leave some dim night lights on
            if let hallwayLight = lightingSystem.getLight(withId: "L001") {
                hallwayLight.turnOn()
                hallwayLight.setBrightness(10)
            }
            
            // Climate: Cooler sleeping temperature
            if let bedroomZone = climateSystem.getZone(withId: "Z002") {
                bedroomZone.setAllTargetTemperatures(19.0) // 19°C for sleeping
            }
            
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(19.0) // 19°C
            }
            
            // Security: Full protection
            securitySystem.armStay()
            
            // Entertainment: Off
            entertainmentSystem.turnAllPlayersOff()
            
        case .away:
            // Lighting: Simulate occupancy
            lightingSystem.turnAllLightsOff()
            
            // Schedule random lights to turn on/off
            print("🏠 Scheduling random light patterns to simulate occupancy")
            
            // Climate: Energy saving mode
            climateSystem.setAwayMode(true)
            
            // Security: Full protection
            securitySystem.armAway()
            
            // Entertainment: Off
            entertainmentSystem.turnAllPlayersOff()
            
            // Set home state
            isHomeOccupied = false
            
        case .vacation:
            // Lighting: Simulate occupancy with more variation
            lightingSystem.turnAllLightsOff()
            
            // Schedule random lights to turn on/off with more variation
            print("🏠 Scheduling varied light patterns to simulate occupancy during vacation")
            
            // Climate: Maximum energy saving
            climateSystem.setAwayMode(true)
            
            // Security: Maximum protection
            securitySystem.armAway()
            securitySystem.handleSecurityEvent(deviceId: "C001", eventType: "motion") // Start recording on front door camera
            securitySystem.handleSecurityEvent(deviceId: "C002", eventType: "motion") // Start recording on back door camera
            
            // Entertainment: Off
            entertainmentSystem.turnAllPlayersOff()
            
            // Set home state
            isHomeOccupied = false
            
        case .movie:
            // Lighting: Dim lights for movie viewing
            lightingSystem.turnAllLightsOff()
            
            if let livingRoomAccent = lightingSystem.getLight(withId: "L004") {
                livingRoomAccent.turnOn()
                livingRoomAccent.setBrightness(20)
                livingRoomAccent.setColor(RGBColor(red: 0, green: 0, blue: 255)) // Blue accent
            }
            
            // Climate: Comfortable viewing temperature
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(21.5) // 21.5°C
            }
            
            // Security: Stay mode
            securitySystem.armStay()
            
            // Entertainment: Set up for movie
            if let livingRoomTV = entertainmentSystem.getPlayer(withId: "E001") as? SmartTV {
                livingRoomTV.turnOn()
                livingRoomTV.setVolume(60)
                livingRoomTV.setInput("HDMI")
            }
            
            if let soundSystem = entertainmentSystem.getPlayer(withId: "E003") as? SoundSystem {
                soundSystem.turnOn()
                soundSystem.setVolume(70)
                soundSystem.setSurroundMode(true)
                soundSystem.setEqualizer(bass: 2, mid: 0, treble: 1)
            }
            
        case .party:
            // Lighting: Colorful, dynamic lighting
            if let livingRoomGroup = lightingSystem.getGroup(withId: "G001") {
                livingRoomGroup.turnAllOn()
                livingRoomGroup.setAllBrightness(80)
                livingRoomGroup.setAllColor(RGBColor(red: 0, green: 0, blue: 255)) // Blue
            }
            
            if let kitchenGroup = lightingSystem.getGroup(withId: "G002") {
                kitchenGroup.turnAllOn()
                kitchenGroup.setAllBrightness(90)
                kitchenGroup.setAllColor(RGBColor(red: 255, green: 0, blue: 255)) // Purple
            }
            
            // Climate: Cooler for gathering
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(20.0) // 20°C for a crowd
            }
            
            // Security: Disarm
            securitySystem.disarm()
            
            // Entertainment: Party music
            if let soundSystem = entertainmentSystem.getPlayer(withId: "E003") as? SoundSystem {
                soundSystem.turnOn()
                soundSystem.setVolume(85)
                soundSystem.setSurroundMode(true)
                soundSystem.setEqualizer(bass: 5, mid: 2, treble: 3)
                
                let partyMusic = MediaContent(
                    title: "Party Playlist",
                    artist: nil,
                    album: nil,
                    duration: nil,
                    type: .music,
                    source: .streaming
                )
                
                _ = soundSystem.playMedia(partyMusic)
            }
            
            if let kitchenSpeaker = entertainmentSystem.getPlayer(withId: "E004") {
                kitchenSpeaker.turnOn()
                kitchenSpeaker.setVolume(80)
                
                let partyMusic = MediaContent(
                    title: "Party Playlist",
                    artist: nil,
                    album: nil,
                    duration: nil,
                    type: .music,
                    source: .streaming
                )
                
                _ = kitchenSpeaker.playMedia(partyMusic)
            }
            
        case .dinner:
            // Lighting: Warm, medium brightness
            if let livingRoomGroup = lightingSystem.getGroup(withId: "G001") {
                livingRoomGroup.turnAllOn()
                livingRoomGroup.setAllBrightness(60)
                livingRoomGroup.setAllColor(RGBColor(red: 255, green: 180, blue: 100)) // Warm
            }
            
            if let kitchenGroup = lightingSystem.getGroup(withId: "G002") {
                kitchenGroup.turnAllOn()
                kitchenGroup.setAllBrightness(80)
            }
            
            // Climate: Comfortable dining temperature
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(22.0) // 22°C
            }
            
            // Security: Stay mode
            securitySystem.armStay()
            
            // Entertainment: Dinner music
            if let soundSystem = entertainmentSystem.getPlayer(withId: "E003") as? SoundSystem {
                soundSystem.turnOn()
                soundSystem.setVolume(30) // Low background music
                
                let dinnerMusic = MediaContent(
                    title: "Dinner Jazz",
                    artist: nil,
                    album: nil,
                    duration: nil,
                    type: .music,
                    source: .streaming
                )
                
                _ = soundSystem.playMedia(dinnerMusic)
            }
            
        case .reading:
            // Lighting: Focused reading light
            lightingSystem.turnAllLightsOff()
            
            if let livingRoomMain = lightingSystem.getLight(withId: "L001") {
                livingRoomMain.turnOn()
                livingRoomMain.setBrightness(70)
            }
            
            // Climate: Comfortable reading temperature
            if let mainFloorZone = climateSystem.getZone(withId: "Z001") {
                mainFloorZone.setAllTargetTemperatures(21.5) // 21.5°C
            }
            
            // Security: Stay mode
            securitySystem.armStay()
            
            // Entertainment: Soft background music
            if let soundSystem = entertainmentSystem.getPlayer(withId: "E003") as? SoundSystem {
                soundSystem.turnOn()
                soundSystem.setVolume(20) // Very low background music
                
                let readingMusic = MediaContent(
                    title: "Classical Piano",
                    artist: nil,
                    album: nil,
                    duration: nil,
                    type: .music,
                    source: .streaming
                )
                
                _ = soundSystem.playMedia(readingMusic)
            }
        }
        
        print("\n✅ Scene '\(scene.rawValue)' activated successfully\n")
    }
    
    // Arrive home - convenience method
    func arriveHome() {
        print("\n🏠 Welcome home! Preparing your home...\n")
        
        isHomeOccupied = true
        
        // Disarm security
        securitySystem.disarm()
        
        // Turn on appropriate lights based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 6 && hour < 12 {
            setScene(.morning)
        } else if hour >= 12 && hour < 17 {
            setScene(.day)
        } else if hour >= 17 && hour < 22 {
            setScene(.evening)
        } else {
            setScene(.night)
        }
        
        // Adjust climate
        climateSystem.setAwayMode(false)
        climateSystem.setEcoMode(false)
        
        print("\n✅ Home prepared for your arrival\n")
    }
    
    // Leave home - convenience method
    func leaveHome() {
        print("\n🏠 Preparing home for your departure...\n")
        
        // Set away scene
        setScene(.away)
        
        print("\n✅ Home secured for your departure\n")
    }
    
    // Go to bed - convenience method
    func goToBed() {
        print("\n🏠 Preparing home for bedtime...\n")
        
        // Set night scene
        setScene(.night)
        
        print("\n✅ Home prepared for bedtime\n")
    }
    
    // Start vacation mode - convenience method
    func startVacationMode() {
        print("\n🏠 Activating vacation mode...\n")
        
        // Set vacation scene
        setScene(.vacation)
        
        print("\n✅ Vacation mode activated\n")
    }
    
    // End vacation mode - convenience method
    func endVacationMode() {
        print("\n🏠 Ending vacation mode...\n")
        
        // Return home
        arriveHome()
        
        print("\n✅ Vacation mode deactivated\n")
    }
    
    // MARK: - Direct Subsystem Access Methods
    
    // These methods provide direct access to subsystems when needed
    // while still maintaining the simplicity of the facade
    
    // Get the lighting system for direct access
    func getLightingSystem() -> LightingSystem {
        return lightingSystem
    }
    
    // Get the security system for direct access
    func getSecuritySystem() -> SecuritySystem {
        return securitySystem
    }
    
    // Get the climate system for direct access
    func getClimateSystem() -> ClimateSystem {
        return climateSystem
    }
    
    // Get the entertainment system for direct access
    func getEntertainmentSystem() -> EntertainmentSystem {
        return entertainmentSystem
    }
    
    // MARK: - Status Methods
    
    // Get overall home status
    func getHomeStatus() -> String {
        var status = "=== Smart Home Status ===\n"
        status += "Home Occupied: \(isHomeOccupied ? "Yes" : "No")\n"
        
        if let scene = currentScene {
            status += "Current Scene: \(scene.rawValue)\n"
        } else {
            status += "Current Scene: Custom\n"
        }
        
        status += "\n--- Subsystem Summaries ---\n"
        
        // Lighting summary
        let lightCount = lightingSystem.getSystemStatus().components(separatedBy: "\n").count
        status += "Lighting: \(lightCount) devices\n"
        
        // Security summary
        status += "Security: \(securitySystem.isArmed ? "Armed - \(securitySystem.armingMode) Mode" : "Disarmed")\n"
        
        // Climate summary
        let thermostats = climateSystem.getSystemStatus().components(separatedBy: "Individual Thermostats:")[1].components(separatedBy: "\n\n")[0]
        let thermostatCount = thermostats.components(separatedBy: "\n").count - 1
        status += "Climate: \(thermostatCount) thermostats\n"
        
        // Entertainment summary
        let players = entertainmentSystem.getSystemStatus().components(separatedBy: "Individual Players:")[1].components(separatedBy: "\n\n")[0]
        let playerCount = players.components(separatedBy: "\n").count - 1
        status += "Entertainment: \(playerCount) devices\n"
        
        return status
    }
    
    // Get detailed status of all systems
    func getDetailedStatus() -> String {
        var status = getHomeStatus()
        
        status += "\n\n=== Detailed Subsystem Status ===\n\n"
        
        // Lighting details
        status += lightingSystem.getSystemStatus()
        status += "\n\n"
        
        // Security details
        status += securitySystem.getSystemStatus()
        status += "\n\n"
        
        // Climate details
        status += climateSystem.getSystemStatus()
        status += "\n\n"
        
        // Entertainment details
        status += entertainmentSystem.getSystemStatus()
        
        return status
    }
}
