// LightingSystem.swift - Complex subsystem for home lighting

import Foundation

// Light device protocol
protocol Light {
    var id: String { get }
    var name: String { get }
    var isOn: Bool { get }
    var brightness: Int { get } // 0-100%
    var color: RGBColor? { get } // nil for non-RGB lights
    
    func turnOn()
    func turnOff()
    func setBrightness(_ level: Int)
    func setColor(_ color: RGBColor?)
    func getStatus() -> String
}

// RGB Color structure
struct RGBColor {
    let red: Int   // 0-255
    let green: Int // 0-255
    let blue: Int  // 0-255
    
    init(red: Int, green: Int, blue: Int) {
        self.red = min(255, max(0, red))
        self.green = min(255, max(0, green))
        self.blue = min(255, max(0, blue))
    }
    
    // Predefined colors
    static let white = RGBColor(red: 255, green: 255, blue: 255)
    static let red = RGBColor(red: 255, green: 0, blue: 0)
    static let green = RGBColor(red: 0, green: 255, blue: 0)
    static let blue = RGBColor(red: 0, green: 0, blue: 255)
    static let yellow = RGBColor(red: 255, green: 255, blue: 0)
    static let purple = RGBColor(red: 128, green: 0, blue: 128)
    static let orange = RGBColor(red: 255, green: 165, blue: 0)
    
    var description: String {
        return "RGB(\(red), \(green), \(blue))"
    }
}

// Standard light implementation
class StandardLight: Light {
    let id: String
    let name: String
    private(set) var isOn: Bool = false
    private(set) var brightness: Int = 100
    var color: RGBColor? = nil // Standard lights don't support color
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func turnOn() {
        isOn = true
        print("🔆 Light '\(name)' turned ON")
    }
    
    func turnOff() {
        isOn = false
        print("⚫ Light '\(name)' turned OFF")
    }
    
    func setBrightness(_ level: Int) {
        brightness = min(100, max(0, level))
        print("🔆 Light '\(name)' brightness set to \(brightness)%")
    }
    
    func setColor(_ color: RGBColor?) {
        print("⚠️ Light '\(name)' does not support color")
    }
    
    func getStatus() -> String {
        return "Light: \(name) [\(id)] - Status: \(isOn ? "ON" : "OFF"), Brightness: \(brightness)%"
    }
}

// RGB light implementation
class RGBLight: Light {
    let id: String
    let name: String
    private(set) var isOn: Bool = false
    private(set) var brightness: Int = 100
    private(set) var color: RGBColor? = RGBColor.white
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func turnOn() {
        isOn = true
        print("🔆 RGB Light '\(name)' turned ON")
    }
    
    func turnOff() {
        isOn = false
        print("⚫ RGB Light '\(name)' turned OFF")
    }
    
    func setBrightness(_ level: Int) {
        brightness = min(100, max(0, level))
        print("🔆 RGB Light '\(name)' brightness set to \(brightness)%")
    }
    
    func setColor(_ color: RGBColor?) {
        if let newColor = color {
            self.color = newColor
            print("🔆 RGB Light '\(name)' color set to \(newColor.description)")
        }
    }
    
    func getStatus() -> String {
        var status = "RGB Light: \(name) [\(id)] - Status: \(isOn ? "ON" : "OFF"), Brightness: \(brightness)%"
        if let color = color {
            status += ", Color: \(color.description)"
        }
        return status
    }
}

// Light group for controlling multiple lights together
class LightGroup {
    let id: String
    let name: String
    private var lights: [Light]
    
    init(id: String, name: String, lights: [Light] = []) {
        self.id = id
        self.name = name
        self.lights = lights
    }
    
    func addLight(_ light: Light) {
        lights.append(light)
    }
    
    func removeLight(withId id: String) {
        lights.removeAll { $0.id == id }
    }
    
    func turnAllOn() {
        print("💡 Turning ON all lights in group '\(name)'")
        for light in lights {
            light.turnOn()
        }
    }
    
    func turnAllOff() {
        print("🔌 Turning OFF all lights in group '\(name)'")
        for light in lights {
            light.turnOff()
        }
    }
    
    func setAllBrightness(_ level: Int) {
        print("🔆 Setting brightness to \(level)% for all lights in group '\(name)'")
        for light in lights {
            light.setBrightness(level)
        }
    }
    
    func setAllColor(_ color: RGBColor?) {
        if let color = color {
            print("🎨 Setting color to \(color.description) for all RGB lights in group '\(name)'")
            for light in lights {
                light.setColor(color)
            }
        }
    }
    
    func getStatus() -> String {
        var status = "Light Group: \(name) [\(id)] - \(lights.count) lights\n"
        for light in lights {
            status += "  - \(light.getStatus())\n"
        }
        return status
    }
}

// Lighting system that manages all lights and groups
class LightingSystem {
    private var lights: [String: Light] = [:]
    private var groups: [String: LightGroup] = [:]
    
    // Add a light to the system
    func addLight(_ light: Light) {
        lights[light.id] = light
        print("➕ Added light '\(light.name)' to the system")
    }
    
    // Remove a light from the system
    func removeLight(withId id: String) {
        if let light = lights[id] {
            lights.removeValue(forKey: id)
            print("➖ Removed light '\(light.name)' from the system")
            
            // Also remove from any groups
            for (_, group) in groups {
                group.removeLight(withId: id)
            }
        }
    }
    
    // Get a light by ID
    func getLight(withId id: String) -> Light? {
        return lights[id]
    }
    
    // Add a light group to the system
    func addGroup(_ group: LightGroup) {
        groups[group.id] = group
        print("➕ Added light group '\(group.name)' to the system")
    }
    
    // Remove a light group from the system
    func removeGroup(withId id: String) {
        if let group = groups[id] {
            groups.removeValue(forKey: id)
            print("➖ Removed light group '\(group.name)' from the system")
        }
    }
    
    // Get a light group by ID
    func getGroup(withId id: String) -> LightGroup? {
        return groups[id]
    }
    
    // Turn on all lights in the system
    func turnAllLightsOn() {
        print("💡 Turning ON all lights in the system")
        for (_, light) in lights {
            light.turnOn()
        }
    }
    
    // Turn off all lights in the system
    func turnAllLightsOff() {
        print("🔌 Turning OFF all lights in the system")
        for (_, light) in lights {
            light.turnOff()
        }
    }
    
    // Set all lights to a specific brightness
    func setAllLightsBrightness(_ level: Int) {
        print("🔆 Setting brightness to \(level)% for all lights in the system")
        for (_, light) in lights {
            light.setBrightness(level)
        }
    }
    
    // Set all RGB lights to a specific color
    func setAllLightsColor(_ color: RGBColor?) {
        if let color = color {
            print("🎨 Setting color to \(color.description) for all RGB lights in the system")
            for (_, light) in lights {
                light.setColor(color)
            }
        }
    }
    
    // Get status of all lights
    func getSystemStatus() -> String {
        var status = "=== Lighting System Status ===\n"
        status += "Total Lights: \(lights.count)\n"
        status += "Total Groups: \(groups.count)\n\n"
        
        status += "Individual Lights:\n"
        for (_, light) in lights {
            status += "  - \(light.getStatus())\n"
        }
        
        status += "\nLight Groups:\n"
        for (_, group) in groups {
            status += "  - Group: \(group.name) [\(group.id)]\n"
        }
        
        return status
    }
    
    // Create a scene with predefined light settings
    func createScene(name: String, settings: [(lightId: String, brightness: Int, color: RGBColor?)]) -> Bool {
        print("🎬 Creating lighting scene '\(name)'")
        
        for setting in settings {
            if let light = getLight(withId: setting.lightId) {
                light.setBrightness(setting.brightness)
                light.setColor(setting.color)
                if setting.brightness > 0 {
                    light.turnOn()
                } else {
                    light.turnOff()
                }
            } else {
                print("⚠️ Light with ID '\(setting.lightId)' not found")
                return false
            }
        }
        
        return true
    }
    
    // Initialize with some default lights and groups
    func setupDefaultConfiguration() {
        // Create some standard lights
        let livingRoomMain = StandardLight(id: "L001", name: "Living Room Main")
        let kitchenMain = StandardLight(id: "L002", name: "Kitchen Main")
        let bedroomMain = StandardLight(id: "L003", name: "Bedroom Main")
        
        // Create some RGB lights
        let livingRoomAccent = RGBLight(id: "L004", name: "Living Room Accent")
        let kitchenUnder = RGBLight(id: "L005", name: "Kitchen Under Cabinet")
        let bedroomAccent = RGBLight(id: "L006", name: "Bedroom Accent")
        
        // Add all lights to the system
        addLight(livingRoomMain)
        addLight(kitchenMain)
        addLight(bedroomMain)
        addLight(livingRoomAccent)
        addLight(kitchenUnder)
        addLight(bedroomAccent)
        
        // Create groups
        let livingRoomGroup = LightGroup(id: "G001", name: "Living Room")
        livingRoomGroup.addLight(livingRoomMain)
        livingRoomGroup.addLight(livingRoomAccent)
        
        let kitchenGroup = LightGroup(id: "G002", name: "Kitchen")
        kitchenGroup.addLight(kitchenMain)
        kitchenGroup.addLight(kitchenUnder)
        
        let bedroomGroup = LightGroup(id: "G003", name: "Bedroom")
        bedroomGroup.addLight(bedroomMain)
        bedroomGroup.addLight(bedroomAccent)
        
        // Add groups to the system
        addGroup(livingRoomGroup)
        addGroup(kitchenGroup)
        addGroup(bedroomGroup)
        
        print("✅ Default lighting configuration set up successfully")
    }
}
