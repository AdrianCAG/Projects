//
//  AudioManager.swift
//  Ambient Audio Capture App
//
//  Created by Adrian on 10/3/25.
//

import Foundation
import AVFoundation
import Combine
import AppKit




// MARK: - CLASS 2: Audio Manager (Handles all audio recording)
class AudioManager: ObservableObject {
    @Published var isRecording = false
    @Published var audioLevel: Float = 0
    @Published var recordingDuration: TimeInterval = 0
    @Published var availableDevices: [AudioDevice] = []
    @Published var selectedDeviceID: String?
    @Published var saveFolder: URL?
    @Published var audioFormat: AudioFormat = .wav
    
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var recordingStartTime: Date?
    private var timer: Timer?
    
    init() {
        loadDevices()
        loadSettings()
        ensureDefaultSaveFolder()
    }
    
    // MARK: - Device Management
    
    func loadDevices() {
        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInMicrophone, .externalUnknown],
            mediaType: .audio,
            position: .unspecified
        ).devices
        
        availableDevices = devices.map { AudioDevice(id: $0.uniqueID, name: $0.localizedName) }
        
        // Auto-select Blue Yeti if found
        if selectedDeviceID == nil {
            selectedDeviceID = availableDevices.first { $0.name.contains("Yeti") }?.id
                ?? availableDevices.first?.id
        }
    }
    
    // MARK: - Recording Control
    
    func startRecording() {
        guard !isRecording else { return }
        guard let folder = saveFolder else {
            print("❌ No save folder selected")
            return
        }

        ensureMicrophoneAccess { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                print("❌ Microphone access denied or restricted. Recording will not start.")
                return
            }

            do {
                self.audioEngine = AVAudioEngine()
                guard let audioEngine = self.audioEngine else { return }

                let inputNode = audioEngine.inputNode
                let inputFormat = inputNode.outputFormat(forBus: 0)

                // Create file
                let fileName = self.generateFileName()
                let fileURL = folder.appendingPathComponent(fileName)

                // Configure file settings to MATCH the tap buffer format to avoid ExtAudioFileWrite -50
                // For WAV/AIFF we will write Float32 PCM (non-interleaved) using the input's sample rate and channel count
                // For M4A (AAC), temporarily fall back to WAV to avoid producing corrupt files until encoder path is added
                let resolvedFormat: AudioFormat = (self.audioFormat == .m4a) ? .wav : self.audioFormat
                if self.audioFormat == .m4a {
                    print("⚠️ M4A not yet supported in this build; saving as WAV instead.")
                }

                let fileSettings: [String: Any]
                switch resolvedFormat {
                case .wav, .aiff:
                    fileSettings = [
                        AVFormatIDKey: kAudioFormatLinearPCM,
                        AVSampleRateKey: inputFormat.sampleRate,
                        AVNumberOfChannelsKey: inputFormat.channelCount,
                        AVLinearPCMBitDepthKey: 32,
                        AVLinearPCMIsBigEndianKey: false,
                        AVLinearPCMIsFloatKey: true,
                        AVLinearPCMIsNonInterleaved: true
                    ]
                case .m4a:
                    // Unused due to early fallback; keep for future AAC support
                    fileSettings = [
                        AVFormatIDKey: kAudioFormatMPEG4AAC,
                        AVSampleRateKey: inputFormat.sampleRate,
                        AVNumberOfChannelsKey: inputFormat.channelCount,
                        AVEncoderBitRateKey: 192000
                    ]
                }

                self.audioFile = try AVAudioFile(
                    forWriting: fileURL,
                    settings: fileSettings,
                    commonFormat: .pcmFormatFloat32,
                    interleaved: false
                )

                guard let audioFile = self.audioFile else { return }

                // Install tap
                inputNode.installTap(onBus: 0, bufferSize: 2048, format: inputFormat) { [weak self] buffer, _ in
                    do {
                        try audioFile.write(from: buffer)
                    } catch {
                        print("❌ Write error: \(error)")
                    }
                    self?.updateAudioLevel(buffer)
                }

                try audioEngine.start()

                DispatchQueue.main.async {
                    self.isRecording = true
                    self.recordingStartTime = Date()

                    // Start timer for duration
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                        guard let start = self?.recordingStartTime else { return }
                        self?.recordingDuration = Date().timeIntervalSince(start)
                    }

                    print("✅ Recording to: \(fileURL.path)")
                }

            } catch {
                print("❌ Recording error: \(error)")
            }
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        audioFile = nil
        
        timer?.invalidate()
        timer = nil
        
        isRecording = false
        audioLevel = 0
        recordingDuration = 0
        
        print("⏹️ Recording stopped")
    }
    
    // MARK: - Microphone Permission (macOS)
    private func ensureMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func updateAudioLevel(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let channelDataValue = channelData.pointee
        var sum: Float = 0
        let frameLength = Int(buffer.frameLength)
        
        for i in 0..<frameLength {
            let sample = channelDataValue[i]
            sum += sample * sample
        }
        
        guard frameLength > 0 else { return }
        let rms = sqrt(sum / Float(frameLength))
        let minRMS: Float = 1e-9
        let db = 20 * log10(max(rms, minRMS))
        let normalized = max(0, min(1, (db + 50) / 50))
        
        DispatchQueue.main.async {
            self.audioLevel = normalized
        }
    }
    
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "Recording_\(timestamp).\(audioFormat.fileExtension)"
    }

    private func ensureDefaultSaveFolder() {
        if saveFolder == nil {
            let defaultFolder = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first?
                .appendingPathComponent("Ambient Recordings", isDirectory: true)
            if let folder = defaultFolder {
                try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                saveFolder = folder
                saveSettings()
                print("📁 Using default save folder: \(folder.path)")
            }
        }
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        if let path = UserDefaults.standard.string(forKey: "saveFolder") {
            saveFolder = URL(fileURLWithPath: path)
        }
        if let deviceID = UserDefaults.standard.string(forKey: "selectedDevice") {
            selectedDeviceID = deviceID
        }
        if let formatString = UserDefaults.standard.string(forKey: "audioFormat"),
           let format = AudioFormat(rawValue: formatString) {
            audioFormat = format
        }
    }
    
    func saveSettings() {
        if let folder = saveFolder {
            UserDefaults.standard.set(folder.path, forKey: "saveFolder")
        }
        if let deviceID = selectedDeviceID {
            UserDefaults.standard.set(deviceID, forKey: "selectedDevice")
        }
        UserDefaults.standard.set(audioFormat.rawValue, forKey: "audioFormat")
    }
    
    func selectSaveFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Choose folder to save recordings"
        
        if panel.runModal() == .OK, let url = panel.url {
            saveFolder = url
            saveSettings()
        }
    }
    
    deinit {
        stopRecording()
    }
}
