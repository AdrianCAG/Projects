// SecuritySystem.swift - Complex subsystem for home security

import Foundation

// Alert level enum
enum AlertLevel: Int {
    case low = 1
    case medium = 2
    case high = 3
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// Security device protocol
protocol SecurityDevice {
    var id: String { get }
    var name: String { get }
    var isActive: Bool { get }
    var isTriggered: Bool { get }
    
    func activate()
    func deactivate()
    func resetAlarm()
    func getStatus() -> String
}

// Security camera implementation
class SecurityCamera: SecurityDevice {
    let id: String
    let name: String
    private(set) var isActive: Bool = false
    private(set) var isTriggered: Bool = false
    private(set) var isRecording: Bool = false
    private(set) var motionDetected: Bool = false
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func activate() {
        isActive = true
        print("🎥 Security camera '\(name)' activated")
    }
    
    func deactivate() {
        isActive = false
        isRecording = false
        print("🎥 Security camera '\(name)' deactivated")
    }
    
    func startRecording() {
        if isActive {
            isRecording = true
            print("🎥 Security camera '\(name)' started recording")
        } else {
            print("⚠️ Cannot start recording - camera '\(name)' is not active")
        }
    }
    
    func stopRecording() {
        isRecording = false
        print("🎥 Security camera '\(name)' stopped recording")
    }
    
    func detectMotion() {
        if isActive {
            motionDetected = true
            isTriggered = true
            print("🚨 Motion detected on camera '\(name)'")
            startRecording()
        }
    }
    
    func resetAlarm() {
        isTriggered = false
        motionDetected = false
        print("🔄 Reset alarm on camera '\(name)'")
    }
    
    func getStatus() -> String {
        var status = "Camera: \(name) [\(id)] - Status: \(isActive ? "Active" : "Inactive")"
        if isActive {
            status += ", Recording: \(isRecording ? "Yes" : "No")"
            status += ", Motion: \(motionDetected ? "Detected" : "None")"
            status += ", Alarm: \(isTriggered ? "Triggered" : "Normal")"
        }
        return status
    }
}

// Door/window sensor implementation
class DoorWindowSensor: SecurityDevice {
    let id: String
    let name: String
    private(set) var isActive: Bool = false
    private(set) var isTriggered: Bool = false
    private(set) var isOpen: Bool = false
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func activate() {
        isActive = true
        print("🚪 Door/window sensor '\(name)' activated")
    }
    
    func deactivate() {
        isActive = false
        print("🚪 Door/window sensor '\(name)' deactivated")
    }
    
    func open() {
        isOpen = true
        if isActive {
            isTriggered = true
            print("🚨 Door/window '\(name)' opened while system active!")
        } else {
            print("🚪 Door/window '\(name)' opened")
        }
    }
    
    func close() {
        isOpen = false
        print("🚪 Door/window '\(name)' closed")
    }
    
    func resetAlarm() {
        isTriggered = false
        print("🔄 Reset alarm on door/window sensor '\(name)'")
    }
    
    func getStatus() -> String {
        var status = "Sensor: \(name) [\(id)] - Status: \(isActive ? "Active" : "Inactive")"
        status += ", Position: \(isOpen ? "Open" : "Closed")"
        if isActive {
            status += ", Alarm: \(isTriggered ? "Triggered" : "Normal")"
        }
        return status
    }
}

// Motion sensor implementation
class MotionSensor: SecurityDevice {
    let id: String
    let name: String
    private(set) var isActive: Bool = false
    private(set) var isTriggered: Bool = false
    private(set) var sensitivity: Int = 5 // 1-10
    
    init(id: String, name: String, sensitivity: Int = 5) {
        self.id = id
        self.name = name
        self.sensitivity = min(10, max(1, sensitivity))
    }
    
    func activate() {
        isActive = true
        print("👁️ Motion sensor '\(name)' activated with sensitivity \(sensitivity)")
    }
    
    func deactivate() {
        isActive = false
        print("👁️ Motion sensor '\(name)' deactivated")
    }
    
    func setSensitivity(_ level: Int) {
        sensitivity = min(10, max(1, level))
        print("👁️ Motion sensor '\(name)' sensitivity set to \(sensitivity)")
    }
    
    func detectMotion() {
        if isActive {
            isTriggered = true
            print("🚨 Motion detected by sensor '\(name)'")
        }
    }
    
    func resetAlarm() {
        isTriggered = false
        print("🔄 Reset alarm on motion sensor '\(name)'")
    }
    
    func getStatus() -> String {
        var status = "Motion Sensor: \(name) [\(id)] - Status: \(isActive ? "Active" : "Inactive")"
        if isActive {
            status += ", Sensitivity: \(sensitivity)/10"
            status += ", Alarm: \(isTriggered ? "Triggered" : "Normal")"
        }
        return status
    }
}

// Alarm system implementation
class AlarmSystem {
    private(set) var isArmed: Bool = false
    private(set) var isSilent: Bool = false
    private(set) var alertLevel: AlertLevel = .medium
    
    func arm(silent: Bool = false) {
        isArmed = true
        isSilent = silent
        print("🔒 Alarm system armed\(silent ? " (silent mode)" : "")")
    }
    
    func disarm() {
        isArmed = false
        print("🔓 Alarm system disarmed")
    }
    
    func setAlertLevel(_ level: AlertLevel) {
        alertLevel = level
        print("⚠️ Alarm alert level set to \(level.description)")
    }
    
    func triggerAlarm(reason: String) {
        if isArmed {
            if isSilent {
                print("🔕 Silent alarm triggered: \(reason)")
            } else {
                print("🚨 ALARM TRIGGERED: \(reason)")
                print("🔊 Siren activated at alert level \(alertLevel.description)")
            }
        }
    }
    
    func getStatus() -> String {
        return "Alarm System - Status: \(isArmed ? "Armed" : "Disarmed")\(isArmed && isSilent ? " (Silent)" : ""), Alert Level: \(alertLevel.description)"
    }
}

// Security system that manages all security devices
class SecuritySystem {
    private var cameras: [String: SecurityCamera] = [:]
    private var doorWindowSensors: [String: DoorWindowSensor] = [:]
    private var motionSensors: [String: MotionSensor] = [:]
    private let alarmSystem = AlarmSystem()
    
    private(set) var isArmed: Bool = false
    private(set) var armingMode: String = "Off" // "Off", "Stay", "Away"
    
    // Add a security camera to the system
    func addCamera(_ camera: SecurityCamera) {
        cameras[camera.id] = camera
        print("➕ Added camera '\(camera.name)' to the system")
    }
    
    // Remove a security camera from the system
    func removeCamera(withId id: String) {
        if let camera = cameras[id] {
            cameras.removeValue(forKey: id)
            print("➖ Removed camera '\(camera.name)' from the system")
        }
    }
    
    // Get a camera by ID
    func getCamera(withId id: String) -> SecurityCamera? {
        return cameras[id]
    }
    
    // Add a door/window sensor to the system
    func addDoorWindowSensor(_ sensor: DoorWindowSensor) {
        doorWindowSensors[sensor.id] = sensor
        print("➕ Added door/window sensor '\(sensor.name)' to the system")
    }
    
    // Remove a door/window sensor from the system
    func removeDoorWindowSensor(withId id: String) {
        if let sensor = doorWindowSensors[id] {
            doorWindowSensors.removeValue(forKey: id)
            print("➖ Removed door/window sensor '\(sensor.name)' from the system")
        }
    }
    
    // Get a door/window sensor by ID
    func getDoorWindowSensor(withId id: String) -> DoorWindowSensor? {
        return doorWindowSensors[id]
    }
    
    // Add a motion sensor to the system
    func addMotionSensor(_ sensor: MotionSensor) {
        motionSensors[sensor.id] = sensor
        print("➕ Added motion sensor '\(sensor.name)' to the system")
    }
    
    // Remove a motion sensor from the system
    func removeMotionSensor(withId id: String) {
        if let sensor = motionSensors[id] {
            motionSensors.removeValue(forKey: id)
            print("➖ Removed motion sensor '\(sensor.name)' from the system")
        }
    }
    
    // Get a motion sensor by ID
    func getMotionSensor(withId id: String) -> MotionSensor? {
        return motionSensors[id]
    }
    
    // Arm the security system in "Stay" mode (perimeter only)
    func armStay() {
        print("🔒 Arming security system in STAY mode")
        
        // Activate door/window sensors
        for (_, sensor) in doorWindowSensors {
            sensor.activate()
        }
        
        // Activate only perimeter motion sensors
        for (_, sensor) in motionSensors {
            if sensor.name.contains("Perimeter") {
                sensor.activate()
            }
        }
        
        // Activate cameras but don't record
        for (_, camera) in cameras {
            camera.activate()
        }
        
        // Arm the alarm system
        alarmSystem.arm(silent: false)
        
        isArmed = true
        armingMode = "Stay"
    }
    
    // Arm the security system in "Away" mode (full protection)
    func armAway() {
        print("🔒 Arming security system in AWAY mode")
        
        // Activate all sensors
        for (_, sensor) in doorWindowSensors {
            sensor.activate()
        }
        
        for (_, sensor) in motionSensors {
            sensor.activate()
        }
        
        // Activate all cameras and start recording
        for (_, camera) in cameras {
            camera.activate()
            camera.startRecording()
        }
        
        // Arm the alarm system
        alarmSystem.arm(silent: false)
        
        isArmed = true
        armingMode = "Away"
    }
    
    // Disarm the security system
    func disarm() {
        print("🔓 Disarming security system")
        
        // Deactivate all sensors
        for (_, sensor) in doorWindowSensors {
            sensor.deactivate()
        }
        
        for (_, sensor) in motionSensors {
            sensor.deactivate()
        }
        
        // Stop recording but keep cameras active
        for (_, camera) in cameras {
            camera.stopRecording()
        }
        
        // Disarm the alarm system
        alarmSystem.disarm()
        
        isArmed = false
        armingMode = "Off"
    }
    
    // Handle a security event
    func handleSecurityEvent(deviceId: String, eventType: String) {
        var deviceInfo = "Unknown device"
        var shouldTriggerAlarm = false
        
        // Check if it's a camera
        if let camera = cameras[deviceId] {
            deviceInfo = "Camera '\(camera.name)'"
            
            if eventType == "motion" {
                camera.detectMotion()
                shouldTriggerAlarm = isArmed
            }
        }
        // Check if it's a door/window sensor
        else if let sensor = doorWindowSensors[deviceId] {
            deviceInfo = "Door/Window '\(sensor.name)'"
            
            if eventType == "open" {
                sensor.open()
                shouldTriggerAlarm = isArmed
            } else if eventType == "close" {
                sensor.close()
            }
        }
        // Check if it's a motion sensor
        else if let sensor = motionSensors[deviceId] {
            deviceInfo = "Motion Sensor '\(sensor.name)'"
            
            if eventType == "motion" {
                sensor.detectMotion()
                shouldTriggerAlarm = isArmed
            }
        }
        
        // Trigger the alarm if necessary
        if shouldTriggerAlarm {
            alarmSystem.triggerAlarm(reason: "Security event detected by \(deviceInfo)")
        }
    }
    
    // Reset all alarms
    func resetAllAlarms() {
        print("🔄 Resetting all security alarms")
        
        for (_, camera) in cameras {
            camera.resetAlarm()
        }
        
        for (_, sensor) in doorWindowSensors {
            sensor.resetAlarm()
        }
        
        for (_, sensor) in motionSensors {
            sensor.resetAlarm()
        }
    }
    
    // Get status of all security devices
    func getSystemStatus() -> String {
        var status = "=== Security System Status ===\n"
        status += "System: \(isArmed ? "Armed - \(armingMode) Mode" : "Disarmed")\n"
        status += "\(alarmSystem.getStatus())\n\n"
        
        status += "Cameras (\(cameras.count)):\n"
        for (_, camera) in cameras {
            status += "  - \(camera.getStatus())\n"
        }
        
        status += "\nDoor/Window Sensors (\(doorWindowSensors.count)):\n"
        for (_, sensor) in doorWindowSensors {
            status += "  - \(sensor.getStatus())\n"
        }
        
        status += "\nMotion Sensors (\(motionSensors.count)):\n"
        for (_, sensor) in motionSensors {
            status += "  - \(sensor.getStatus())\n"
        }
        
        return status
    }
    
    // Initialize with some default security devices
    func setupDefaultConfiguration() {
        // Create cameras
        let frontDoorCamera = SecurityCamera(id: "C001", name: "Front Door Camera")
        let backDoorCamera = SecurityCamera(id: "C002", name: "Back Door Camera")
        let livingRoomCamera = SecurityCamera(id: "C003", name: "Living Room Camera")
        
        // Create door/window sensors
        let frontDoorSensor = DoorWindowSensor(id: "D001", name: "Front Door")
        let backDoorSensor = DoorWindowSensor(id: "D002", name: "Back Door")
        let kitchenWindowSensor = DoorWindowSensor(id: "D003", name: "Kitchen Window")
        let livingRoomWindowSensor = DoorWindowSensor(id: "D004", name: "Living Room Window")
        let bedroomWindowSensor = DoorWindowSensor(id: "D005", name: "Bedroom Window")
        
        // Create motion sensors
        let frontYardSensor = MotionSensor(id: "M001", name: "Front Yard Perimeter", sensitivity: 7)
        let backYardSensor = MotionSensor(id: "M002", name: "Back Yard Perimeter", sensitivity: 7)
        let livingRoomSensor = MotionSensor(id: "M003", name: "Living Room", sensitivity: 5)
        let kitchenSensor = MotionSensor(id: "M004", name: "Kitchen", sensitivity: 5)
        let hallwaySensor = MotionSensor(id: "M005", name: "Hallway", sensitivity: 6)
        
        // Add all devices to the system
        addCamera(frontDoorCamera)
        addCamera(backDoorCamera)
        addCamera(livingRoomCamera)
        
        addDoorWindowSensor(frontDoorSensor)
        addDoorWindowSensor(backDoorSensor)
        addDoorWindowSensor(kitchenWindowSensor)
        addDoorWindowSensor(livingRoomWindowSensor)
        addDoorWindowSensor(bedroomWindowSensor)
        
        addMotionSensor(frontYardSensor)
        addMotionSensor(backYardSensor)
        addMotionSensor(livingRoomSensor)
        addMotionSensor(kitchenSensor)
        addMotionSensor(hallwaySensor)
        
        // Set alert level
        alarmSystem.setAlertLevel(.medium)
        
        print("✅ Default security configuration set up successfully")
    }
}
