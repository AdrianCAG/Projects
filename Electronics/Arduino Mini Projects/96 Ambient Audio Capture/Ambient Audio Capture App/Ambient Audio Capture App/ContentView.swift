//
//  ContentView.swift
//  Ambient Audio Capture App
//
//  Created by Adrian on 10/3/25.
//

import SwiftUI






// MARK: - SINGLE UI VIEW
struct ContentView: View {
    @StateObject private var arduino = ArduinoManager()
    @StateObject private var audio = AudioManager()
    @State private var threshold: Double = 300
    
    var body: some View {
        HSplitView {
            // Left Panel - Controls
            VStack(alignment: .leading, spacing: 20) {
                // Arduino Section
                GroupBox(label: Text("Arduino Connection").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Circle()
                                .fill(arduino.isConnected ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(arduino.isConnected ? "Connected" : "Disconnected")
                                .foregroundColor(.secondary)
                        }
                        
                        // Arduino Port Picker
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Serial Port:")
                                .font(.subheadline)
                            
                            HStack {
                                Picker("", selection: $arduino.selectedPortPath) {
                                    if arduino.availablePorts.isEmpty {
                                        Text("No ports found").tag(nil as String?)
                                    } else {
                                        ForEach(arduino.availablePorts) { port in
                                            Text(port.name).tag(port.path as String?)
                                        }
                                    }
                                }
                                .labelsHidden()
                                .disabled(arduino.isConnected)
                                .onChange(of: arduino.selectedPortPath) { _ in
                                    arduino.saveSettings()
                                }
                                
                                Button(action: {
                                    arduino.refreshPorts()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .buttonStyle(.bordered)
                                .help("Refresh serial ports")
                                .disabled(arduino.isConnected)
                            }
                        }
                        
                        HStack {
                            if arduino.isConnected {
                                Button("Disconnect") {
                                    arduino.disconnect()
                                }
//                                Button("Test LEDs") {
//                                    arduino.testLEDs()
//                                }
                            } else {
                                Button("Connect") {
                                    arduino.connect()
                                }
                                .disabled(arduino.selectedPortPath == nil)
                            }
                        }
                    }
                    .padding()
                }
                
                // Recording Section
                GroupBox(label: Text("Recording").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Circle()
                                .fill(audio.isRecording ? Color.red : Color.gray)
                                .frame(width: 10, height: 10)
                            Text(audio.isRecording ? "Recording" : "Idle")
                                .foregroundColor(.secondary)
                        }
                        
                        if audio.isRecording {
                            Text("Duration: \(formatDuration(audio.recordingDuration))")
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        Text("Triggers automatically via sound sensor")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Settings Section
                GroupBox(label: Text("Settings").font(.headline)) {
                    VStack(alignment: .leading, spacing: 15) {
                        // Microphone
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Microphone:")
                                .font(.subheadline)
                            Picker("", selection: $audio.selectedDeviceID) {
                                ForEach(audio.availableDevices) { device in
                                    Text(device.name).tag(device.id as String?)
                                }
                            }
                            .labelsHidden()
                            .onChange(of: audio.selectedDeviceID) { _ in
                                audio.saveSettings()
                            }
                        }
                        
                        // Format
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Audio Format:")
                                .font(.subheadline)
                            Picker("", selection: $audio.audioFormat) {
                                ForEach(AudioFormat.allCases) { format in
                                    Text(format.rawValue).tag(format)
                                }
                            }
                            .labelsHidden()
                            .onChange(of: audio.audioFormat) { _ in
                                audio.saveSettings()
                            }
                        }
                        
                        // Save Folder
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Save Folder:")
                                .font(.subheadline)
                            if let folder = audio.saveFolder {
                                Text(folder.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not selected")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            Button("Choose Folder...") {
                                audio.selectSaveFolder()
                            }
                        }
                        
                        // Threshold
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Sensitivity: \(Int(threshold))")
                                .font(.subheadline)
                            Slider(value: $threshold, in: 0...1023, step: 10)
                                .onChange(of: threshold) { value in
//                                    arduino.setThreshold(Int(value))
                                }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .frame(minWidth: 350, maxWidth: 400)
            
            // Right Panel - Monitoring
            VStack(spacing: 0) {
                // Audio Level Meter
                VStack {
                    Text("Audio Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .yellow, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(audio.audioLevel))
                        }
                        .cornerRadius(8)
                    }
                    .frame(height: 30)
                    .padding(.horizontal)
                }
                .padding()
                .frame(height: 100)
                
                Divider()
                
                // Event Log
                VStack(alignment: .leading) {
                    Text("Arduino Events")
                        .font(.headline)
                        .padding()
                    
                    ScrollView {
                        Text(arduino.lastEvent)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                }
            }
        }
        .onAppear {
            // Load available ports
            arduino.refreshPorts()
            
            // Connect Arduino to Audio
            arduino.onRecordingStart = {
                audio.startRecording()
            }
            arduino.onRecordingStop = {
                audio.stopRecording()
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
