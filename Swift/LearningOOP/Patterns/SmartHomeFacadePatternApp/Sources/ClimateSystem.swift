// ClimateSystem.swift - Complex subsystem for home climate control

import Foundation

// Temperature unit enum
enum TemperatureUnit {
    case celsius
    case fahrenheit
    
    func convert(_ value: Double, to targetUnit: TemperatureUnit) -> Double {
        if self == targetUnit {
            return value
        }
        
        switch (self, targetUnit) {
        case (.celsius, .fahrenheit):
            return value * 9/5 + 32
        case (.fahrenheit, .celsius):
            return (value - 32) * 5/9
        default:
            return value
        }
    }
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

// HVAC mode enum
enum HVACMode: String {
    case off = "Off"
    case heat = "Heat"
    case cool = "Cool"
    case auto = "Auto"
    case fan = "Fan Only"
}

// Fan speed enum
enum FanSpeed: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case auto = "Auto"
}

// Thermostat protocol
protocol Thermostat {
    var id: String { get }
    var name: String { get }
    var currentTemperature: Double { get }
    var targetTemperature: Double { get set }
    var mode: HVACMode { get set }
    var fanSpeed: FanSpeed { get set }
    var isRunning: Bool { get }
    var temperatureUnit: TemperatureUnit { get set }
    
    func turnOn()
    func turnOff()
    func setTargetTemperature(_ temp: Double)
    func setMode(_ mode: HVACMode)
    func setFanSpeed(_ speed: FanSpeed)
    func getStatus() -> String
}

// Basic thermostat implementation
class BasicThermostat: Thermostat {
    let id: String
    let name: String
    private(set) var currentTemperature: Double
    var targetTemperature: Double
    var mode: HVACMode
    var fanSpeed: FanSpeed
    private(set) var isRunning: Bool = false
    var temperatureUnit: TemperatureUnit
    
    init(id: String, name: String, currentTemp: Double, targetTemp: Double, unit: TemperatureUnit = .celsius) {
        self.id = id
        self.name = name
        self.currentTemperature = currentTemp
        self.targetTemperature = targetTemp
        self.mode = .off
        self.fanSpeed = .medium
        self.temperatureUnit = unit
    }
    
    func turnOn() {
        if mode == .off {
            mode = .auto
        }
        isRunning = true
        print("🌡️ Thermostat '\(name)' turned ON in \(mode.rawValue) mode")
    }
    
    func turnOff() {
        mode = .off
        isRunning = false
        print("🌡️ Thermostat '\(name)' turned OFF")
    }
    
    func setTargetTemperature(_ temp: Double) {
        targetTemperature = temp
        print("🌡️ Thermostat '\(name)' target temperature set to \(String(format: "%.1f", temp))\(temperatureUnit.symbol)")
        
        // Auto turn on if setting temperature while off
        if mode == .off {
            turnOn()
        }
    }
    
    func setMode(_ mode: HVACMode) {
        self.mode = mode
        if mode == .off {
            isRunning = false
        } else if !isRunning {
            isRunning = true
        }
        print("🌡️ Thermostat '\(name)' mode set to \(mode.rawValue)")
    }
    
    func setFanSpeed(_ speed: FanSpeed) {
        self.fanSpeed = speed
        print("🌡️ Thermostat '\(name)' fan speed set to \(speed.rawValue)")
    }
    
    func getStatus() -> String {
        var status = "Thermostat: \(name) [\(id)] - Status: \(isRunning ? "Running" : "Off")"
        if isRunning {
            status += ", Mode: \(mode.rawValue)"
            status += ", Current: \(String(format: "%.1f", currentTemperature))\(temperatureUnit.symbol)"
            status += ", Target: \(String(format: "%.1f", targetTemperature))\(temperatureUnit.symbol)"
            status += ", Fan: \(fanSpeed.rawValue)"
        }
        return status
    }
    
    // Simulate temperature change (would be from sensors in real system)
    func updateCurrentTemperature(_ temp: Double) {
        currentTemperature = temp
    }
}

// Smart thermostat with additional features
class SmartThermostat: BasicThermostat {
    private var humidityLevel: Int
    private var schedule: [String: (time: String, temperature: Double)] = [:]
    private var ecoMode: Bool = false
    private var awayMode: Bool = false
    
    init(id: String, name: String, currentTemp: Double, targetTemp: Double, humidity: Int, unit: TemperatureUnit = .celsius) {
        self.humidityLevel = humidity
        super.init(id: id, name: name, currentTemp: currentTemp, targetTemp: targetTemp, unit: unit)
    }
    
    func setHumidity(_ value: Int) {
        humidityLevel = min(100, max(0, value))
    }
    
    func getHumidity() -> Int {
        return humidityLevel
    }
    
    func setSchedule(day: String, time: String, temperature: Double) {
        schedule[day] = (time, temperature)
        print("🌡️ Smart Thermostat '\(name)' schedule set for \(day) at \(time) to \(String(format: "%.1f", temperature))\(temperatureUnit.symbol)")
    }
    
    func clearSchedule(day: String) {
        if schedule.removeValue(forKey: day) != nil {
            print("🌡️ Smart Thermostat '\(name)' schedule for \(day) cleared")
        }
    }
    
    func enableEcoMode(_ enable: Bool) {
        ecoMode = enable
        if enable {
            // In eco mode, adjust target temperature to save energy
            let adjustment = temperatureUnit == .celsius ? 2.0 : 3.6 // 2°C or 3.6°F
            let originalTarget = targetTemperature
            
            if mode == .cool {
                targetTemperature += adjustment // Higher target when cooling
            } else if mode == .heat {
                targetTemperature -= adjustment // Lower target when heating
            }
            
            print("🌡️ Smart Thermostat '\(name)' ECO mode enabled, adjusted from \(String(format: "%.1f", originalTarget))\(temperatureUnit.symbol) to \(String(format: "%.1f", targetTemperature))\(temperatureUnit.symbol)")
        } else {
            print("🌡️ Smart Thermostat '\(name)' ECO mode disabled")
        }
    }
    
    func setAwayMode(_ away: Bool) {
        awayMode = away
        if away {
            let originalTarget = targetTemperature
            
            // Set more extreme temperature when away to save energy
            let adjustment = temperatureUnit == .celsius ? 4.0 : 7.2 // 4°C or 7.2°F
            
            if mode == .cool {
                targetTemperature += adjustment // Much higher target when cooling
            } else if mode == .heat {
                targetTemperature -= adjustment // Much lower target when heating
            }
            
            print("🌡️ Smart Thermostat '\(name)' AWAY mode enabled, adjusted from \(String(format: "%.1f", originalTarget))\(temperatureUnit.symbol) to \(String(format: "%.1f", targetTemperature))\(temperatureUnit.symbol)")
        } else {
            print("🌡️ Smart Thermostat '\(name)' AWAY mode disabled")
        }
    }
    
    override func getStatus() -> String {
        var status = super.getStatus()
        status += ", Humidity: \(humidityLevel)%"
        if ecoMode {
            status += ", ECO Mode: On"
        }
        if awayMode {
            status += ", Away Mode: On"
        }
        if !schedule.isEmpty {
            status += ", Scheduled: Yes"
        }
        return status
    }
}

// Zone control for multi-zone systems
class ClimateZone {
    let id: String
    let name: String
    private var thermostats: [Thermostat]
    
    init(id: String, name: String, thermostats: [Thermostat] = []) {
        self.id = id
        self.name = name
        self.thermostats = thermostats
    }
    
    func addThermostat(_ thermostat: Thermostat) {
        thermostats.append(thermostat)
    }
    
    func removeThermostat(withId id: String) {
        thermostats.removeAll { $0.id == id }
    }
    
    func setAllTargetTemperatures(_ temp: Double) {
        print("🌡️ Setting target temperature to \(String(format: "%.1f", temp)) for all thermostats in zone '\(name)'")
        for thermostat in thermostats {
            thermostat.setTargetTemperature(temp)
        }
    }
    
    func setAllModes(_ mode: HVACMode) {
        print("🌡️ Setting mode to \(mode.rawValue) for all thermostats in zone '\(name)'")
        for thermostat in thermostats {
            thermostat.setMode(mode)
        }
    }
    
    func turnAllOn() {
        print("🌡️ Turning ON all thermostats in zone '\(name)'")
        for thermostat in thermostats {
            thermostat.turnOn()
        }
    }
    
    func turnAllOff() {
        print("🌡️ Turning OFF all thermostats in zone '\(name)'")
        for thermostat in thermostats {
            thermostat.turnOff()
        }
    }
    
    func getStatus() -> String {
        var status = "Climate Zone: \(name) [\(id)] - \(thermostats.count) thermostats\n"
        for thermostat in thermostats {
            status += "  - \(thermostat.getStatus())\n"
        }
        return status
    }
}

// Climate system that manages all thermostats and zones
class ClimateSystem {
    private var thermostats: [String: Thermostat] = [:]
    private var zones: [String: ClimateZone] = [:]
    private var temperatureUnit: TemperatureUnit = .celsius
    
    // Add a thermostat to the system
    func addThermostat(_ thermostat: Thermostat) {
        thermostats[thermostat.id] = thermostat
        print("➕ Added thermostat '\(thermostat.name)' to the system")
    }
    
    // Remove a thermostat from the system
    func removeThermostat(withId id: String) {
        if let thermostat = thermostats[id] {
            thermostats.removeValue(forKey: id)
            print("➖ Removed thermostat '\(thermostat.name)' from the system")
            
            // Also remove from any zones
            for (_, zone) in zones {
                zone.removeThermostat(withId: id)
            }
        }
    }
    
    // Get a thermostat by ID
    func getThermostat(withId id: String) -> Thermostat? {
        return thermostats[id]
    }
    
    // Add a climate zone to the system
    func addZone(_ zone: ClimateZone) {
        zones[zone.id] = zone
        print("➕ Added climate zone '\(zone.name)' to the system")
    }
    
    // Remove a climate zone from the system
    func removeZone(withId id: String) {
        if let zone = zones[id] {
            zones.removeValue(forKey: id)
            print("➖ Removed climate zone '\(zone.name)' from the system")
        }
    }
    
    // Get a climate zone by ID
    func getZone(withId id: String) -> ClimateZone? {
        return zones[id]
    }
    
    // Set the temperature unit for the entire system
    func setTemperatureUnit(_ unit: TemperatureUnit) {
        temperatureUnit = unit
        print("🌡️ System temperature unit set to \(unit == .celsius ? "Celsius" : "Fahrenheit")")
        
        // Update all thermostats to use the new unit
        for (_, thermostat) in thermostats {
            if thermostat.temperatureUnit != unit {
                // Convert the temperature to the new unit
                let convertedTemp = thermostat.temperatureUnit.convert(thermostat.targetTemperature, to: unit)
                
                // We can't directly modify the temperatureUnit property of a constant
                // Instead, we'll set the target temperature in the new unit
                // Note: In a real system, we would need to implement a proper way to change units
                print("🌡️ Converting thermostat '\(thermostat.name)' from \(thermostat.temperatureUnit == .celsius ? "Celsius" : "Fahrenheit") to \(unit == .celsius ? "Celsius" : "Fahrenheit")")
                thermostat.setTargetTemperature(convertedTemp)
            }
        }
    }
    
    // Turn on all thermostats in the system
    func turnAllThermostatsOn() {
        print("🌡️ Turning ON all thermostats in the system")
        for (_, thermostat) in thermostats {
            thermostat.turnOn()
        }
    }
    
    // Turn off all thermostats in the system
    func turnAllThermostatsOff() {
        print("🌡️ Turning OFF all thermostats in the system")
        for (_, thermostat) in thermostats {
            thermostat.turnOff()
        }
    }
    
    // Set all thermostats to a specific mode
    func setAllThermostatsModes(_ mode: HVACMode) {
        print("🌡️ Setting all thermostats to \(mode.rawValue) mode")
        for (_, thermostat) in thermostats {
            thermostat.setMode(mode)
        }
    }
    
    // Set away mode for all smart thermostats
    func setAwayMode(_ away: Bool) {
        print("🌡️ Setting AWAY mode to \(away ? "ON" : "OFF") for all smart thermostats")
        for (_, thermostat) in thermostats {
            if let smartThermostat = thermostat as? SmartThermostat {
                smartThermostat.setAwayMode(away)
            }
        }
    }
    
    // Set eco mode for all smart thermostats
    func setEcoMode(_ eco: Bool) {
        print("🌡️ Setting ECO mode to \(eco ? "ON" : "OFF") for all smart thermostats")
        for (_, thermostat) in thermostats {
            if let smartThermostat = thermostat as? SmartThermostat {
                smartThermostat.enableEcoMode(eco)
            }
        }
    }
    
    // Get status of all thermostats
    func getSystemStatus() -> String {
        var status = "=== Climate System Status ===\n"
        status += "Total Thermostats: \(thermostats.count)\n"
        status += "Total Zones: \(zones.count)\n"
        status += "System Temperature Unit: \(temperatureUnit == .celsius ? "Celsius" : "Fahrenheit")\n\n"
        
        status += "Individual Thermostats:\n"
        for (_, thermostat) in thermostats {
            status += "  - \(thermostat.getStatus())\n"
        }
        
        status += "\nClimate Zones:\n"
        for (_, zone) in zones {
            status += "  - Zone: \(zone.name) [\(zone.id)]\n"
        }
        
        return status
    }
    
    // Initialize with some default thermostats and zones
    func setupDefaultConfiguration() {
        // Create basic thermostats
        let livingRoomThermostat = BasicThermostat(
            id: "T001",
            name: "Living Room",
            currentTemp: 22.5,
            targetTemp: 21.0
        )
        
        let kitchenThermostat = BasicThermostat(
            id: "T002",
            name: "Kitchen",
            currentTemp: 23.0,
            targetTemp: 21.0
        )
        
        // Create smart thermostats
        let masterBedroomThermostat = SmartThermostat(
            id: "T003",
            name: "Master Bedroom",
            currentTemp: 21.0,
            targetTemp: 20.0,
            humidity: 45
        )
        
        let guestBedroomThermostat = SmartThermostat(
            id: "T004",
            name: "Guest Bedroom",
            currentTemp: 22.0,
            targetTemp: 20.0,
            humidity: 48
        )
        
        // Add all thermostats to the system
        addThermostat(livingRoomThermostat)
        addThermostat(kitchenThermostat)
        addThermostat(masterBedroomThermostat)
        addThermostat(guestBedroomThermostat)
        
        // Create zones
        let mainFloorZone = ClimateZone(id: "Z001", name: "Main Floor")
        mainFloorZone.addThermostat(livingRoomThermostat)
        mainFloorZone.addThermostat(kitchenThermostat)
        
        let bedroomZone = ClimateZone(id: "Z002", name: "Bedrooms")
        bedroomZone.addThermostat(masterBedroomThermostat)
        bedroomZone.addThermostat(guestBedroomThermostat)
        
        // Add zones to the system
        addZone(mainFloorZone)
        addZone(bedroomZone)
        
        // Set some schedules for the smart thermostats
        masterBedroomThermostat.setSchedule(day: "Weekday", time: "22:00", temperature: 19.0)
        masterBedroomThermostat.setSchedule(day: "Weekend", time: "23:00", temperature: 19.0)
        
        guestBedroomThermostat.setSchedule(day: "Weekday", time: "22:00", temperature: 19.0)
        guestBedroomThermostat.setSchedule(day: "Weekend", time: "23:00", temperature: 19.0)
        
        print("✅ Default climate configuration set up successfully")
    }
}
