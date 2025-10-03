//
//  ArduinoManager.swift
//  Ambient Audio Capture App
//
//  Created by Adrian on 10/3/25.
//

import Foundation
import Combine






// MARK: - CLASS 1: Arduino Manager (Handles all Arduino communication)
class ArduinoManager: ObservableObject {
    @Published var isConnected = false
    @Published var lastEvent: String = "Select an Arduino to connect..."
    @Published var availablePorts: [SerialPort] = []
    @Published var selectedPortPath: String?

    private var fileDescriptor: Int32 = -1
    private var readSource: DispatchSourceRead?
    private let queue = DispatchQueue(label: "arduino.serial", qos: .userInitiated)
    private var lastRecordingState: Bool?

    var onRecordingStart: (() -> Void)?
    var onRecordingStop: (() -> Void)?

    init() {
        loadPorts()
        loadSettings()
        print("ArduinoManager initialized, available ports loaded: \(availablePorts)")
    }

    // MARK: - Port Discovery

    func loadPorts() {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: "/dev") else {
            availablePorts = []
            print("Failed to list /dev directory for serial ports")
            return
        }

        let patterns = ["cu.usbmodem", "cu.usbserial", "cu.wchusbserial"]
        var ports: [SerialPort] = []

        for file in files {
            for pattern in patterns {
                if file.contains(pattern) {
                    let fullPath = "/dev/\(file)"
                    let displayName = formatPortName(file)
                    ports.append(SerialPort(path: fullPath, name: displayName))
                    print("Detected serial port: \(displayName) at \(fullPath)")
                }
            }
        }

        availablePorts = ports.sorted { $0.name < $1.name }

        // Auto-select first port if none selected
        if selectedPortPath == nil, let firstPort = availablePorts.first {
            selectedPortPath = firstPort.path
            print("Auto-selected first available port: \(firstPort.name)")
        }
    }

    private func formatPortName(_ fileName: String) -> String {
        if fileName.hasPrefix("cu.usbmodem") {
            let id = fileName.replacingOccurrences(of: "cu.usbmodem", with: "")
            return "Arduino (usbmodem\(id))"
        } else if fileName.hasPrefix("cu.usbserial") {
            let id = fileName.replacingOccurrences(of: "cu.usbserial-", with: "")
            return "Serial Device (\(id))"
        } else if fileName.hasPrefix("cu.wchusbserial") {
            let id = fileName.replacingOccurrences(of: "cu.wchusbserial", with: "")
            return "CH340 Arduino (\(id))"
        }
        return fileName
    }

    // MARK: - Connection
    func connect() {
        guard let portPath = selectedPortPath else {
            lastEvent = "❌ No port selected"
            print(lastEvent)
            return
        }

        guard !isConnected else {
            lastEvent = "⚠️ Already connected"
            print(lastEvent)
            return
        }

        fileDescriptor = open(portPath, O_RDWR | O_NOCTTY | O_NONBLOCK)
        guard fileDescriptor != -1 else {
            lastEvent = "❌ Failed to open \(portPath)"
            print(lastEvent)
            return
        }
        print("Opened serial port at path: \(portPath) with file descriptor: \(fileDescriptor)")

        // Configure serial port with raw mode and proper settings
        var options = termios()
        tcgetattr(fileDescriptor, &options)

        // Set raw mode to disable canonical input, echo, signals, and all preprocessing
        cfmakeraw(&options)

        // Set baud rate to 9600 (same for input and output)
        cfsetispeed(&options, speed_t(B9600))
        cfsetospeed(&options, speed_t(B9600))

        // Set 8 data bits, no parity, one stop bit (8N1)
        options.c_cflag &= ~tcflag_t(PARENB)    // Clear parity enable
        options.c_cflag &= ~tcflag_t(CSTOPB)    // Clear stop bits (use one stop bit)
        options.c_cflag &= ~tcflag_t(CSIZE)     // Clear data bits size flag
        options.c_cflag |= tcflag_t(CS8)        // Set 8 data bits

        // Enable receiver, ignore modem controls, no flow control
        options.c_cflag |= tcflag_t(CREAD | CLOCAL)
        options.c_iflag &= ~tcflag_t(IXON | IXOFF | IXANY) // Disable software flow control
        options.c_iflag &= ~tcflag_t(INPCK | ISTRIP) // Disable parity check, stripping bits

        options.c_oflag &= ~tcflag_t(OPOST) // Disable output processing

        // Control characters - VMIN and VTIME
        // Read blocks until at least 1 byte available
        options.c_cc.16 = 1  // VMIN = 1
        options.c_cc.17 = 0  // VTIME = 0 (no timeout)

        // Apply settings immediately
        tcsetattr(fileDescriptor, TCSANOW, &options)

        startReading()

        isConnected = true
        lastEvent = "✅ Connected to \(availablePorts.first(where: { $0.path == portPath })?.name ?? "Arduino")"
        print(lastEvent)
        saveSettings()
    }

    func disconnect() {
        print("Disconnecting...")
        readSource?.cancel()
        readSource = nil
        if fileDescriptor != -1 {
            close(fileDescriptor)
            print("Closed file descriptor \(fileDescriptor)")
            fileDescriptor = -1
        }
        isConnected = false
        lastEvent = "🔌 Disconnected"
        print(lastEvent)
    }

    func refreshPorts() {
        let wasConnected = isConnected
        if wasConnected {
            disconnect()
        }
        loadPorts()
        lastEvent = "🔄 Found \(availablePorts.count) serial port(s)"
        print(lastEvent)
    }

    // MARK: - Reading Data

    private func startReading() {
        guard fileDescriptor != -1 else {
            print("startReading called but fileDescriptor is invalid")
            return
        }
        // print("Starting to read serial data...")
        readSource = DispatchSource.makeReadSource(fileDescriptor: fileDescriptor, queue: queue)
        var buffer = ""

        readSource?.setEventHandler { [weak self] in
            guard let self = self else { return }

            var readBuffer = [UInt8](repeating: 0, count: 128)
            let bytesRead = read(self.fileDescriptor, &readBuffer, readBuffer.count)
            // print("Read \(bytesRead) bytes from serial")

            if bytesRead > 0,
               let string = String(bytes: readBuffer[0..<bytesRead], encoding: .utf8) {
                // print("Raw data read from serial: \(string)")
                buffer += string

                // Try newline-delimited first
                while let range = buffer.range(of: "\n") {
                    let line = String(buffer[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    buffer.removeSubrange(...range.lowerBound)
                    // print("Complete line extracted: \(line)")
                    if !line.isEmpty {
                        DispatchQueue.main.async {
                            self.handleMessage(line)
                        }
                    }
                }

                // Also handle JSON objects without trailing newline by looking for {...}
                while let start = buffer.firstIndex(of: "{"),
                      let end = buffer[start...].firstIndex(of: "}") {
                    let jsonObject = String(buffer[start...end]).trimmingCharacters(in: .whitespacesAndNewlines)
                    // Remove everything up to and including the closing brace
                    buffer.removeSubrange(..<buffer.index(after: end))
                    // print("Complete JSON extracted (no newline): \(jsonObject)")
                    if !jsonObject.isEmpty {
                        DispatchQueue.main.async {
                            self.handleMessage(jsonObject)
                        }
                    }
                }
            } else {
                print("No data read or failed to convert data to string")
            }
        }

        readSource?.resume()
        // print("Serial read source resumed")
    }

    private func handleMessage(_ json: String) {
        let trimmed = json.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.first == "{", trimmed.last == "}" else {
            // print("Ignoring non-JSON line: \(json)")
            return
        }

        guard let data = trimmed.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // print("Failed to parse JSON: \(json)")
            return
        }

        lastEvent = json

        // Prefer explicit recording flag if provided
        if let recording = dict["recording"] as? Bool {
            if lastRecordingState != recording {
                lastRecordingState = recording
                if recording {
                    // print("Recording flag true → starting recording")
                    onRecordingStart?()
                } else {
                    // print("Recording flag false → stopping recording")
                    onRecordingStop?()
                }
            }
        }

        // Also respond to event names when present
        if let event = dict["event"] as? String {
            print("Event received: \(event)")
            switch event {
            case "recording_started":
                onRecordingStart?()
            case "recording_stopped":
                onRecordingStop?()
            case "button_pressed":
                // Fallback: toggle based on last state if no explicit flag provided
                if dict["recording"] == nil {
                    let newState = !(lastRecordingState ?? false)
                    lastRecordingState = newState
                    if newState { onRecordingStart?() } else { onRecordingStop?() }
                }
            default:
                break
            }
        }
    }

    // MARK: - Sending Commands
//    func send(_ command: [String: Any]) {
//        guard fileDescriptor != -1,
//              let data = try? JSONSerialization.data(withJSONObject: command),
//              let string = String(data, encoding: .utf8) else {
//            print("Failed to serialize and send command: \(command)")
//            return
//        }
//
//        let message = string + "\n"
//        print("Sending message to Arduino: \(message)")
//        message.withCString { ptr in
//            let bytesWritten = write(fileDescriptor, ptr, strlen(ptr))
//            print("Bytes written to serial: \(bytesWritten)")
//        }
//    }

//    func setThreshold(_ value: Int) {
//        send(["command": "set_threshold", "value": value])
//    }
//
//    func testLEDs() {
//        send(["command": "test_leds"])
//    }

    // MARK: - Settings Persistence

    private func loadSettings() {
        if let savedPort = UserDefaults.standard.string(forKey: "selectedPort") {
            selectedPortPath = savedPort
            // print("Loaded saved port path from settings: \(savedPort)")
        }
    }

    func saveSettings() {
        if let portPath = selectedPortPath {
            UserDefaults.standard.set(portPath, forKey: "selectedPort")
            // print("Saved selected port path to settings: \(portPath)")
        }
    }

    deinit {
        // print("ArduinoManager deinitialized, disconnecting...")
        disconnect()
    }
}
