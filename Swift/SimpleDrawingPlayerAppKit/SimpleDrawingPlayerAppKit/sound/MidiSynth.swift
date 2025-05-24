//
//  MidiSynth.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//

import AppKit



protocol SoundProducer {
    // Protocol defining the interface for sound production
    func play(instrument: Int, note: Int, velocity: Int)
    func stop(instrument: Int, note: Int)
}


// Simple sound producer class that uses NSSound for direct sound generation
class MidiSynth: NSObject, SoundProducer {
    
    // Dictionary to keep track of active sounds for each instrument and note
    private var activeSounds: [Int: [Int: NSSound]] = [:]
    private var channels: [ChannelData] = []
    private var channelMap: [Int: ChannelData] = [:]
    
    // MODIFIES: this
    // EFFECTS:  prepares instruments, channels for playback
    func open() {
        setupChannels()
        // NSSound doesn't have systemVolume property
        print("MidiSynth opened and configured for output - using NSSound")
    }
    
    // EFFECTS: synthesizes sound given instrument, note, and velocity
    func play(instrument: Int, note: Int, velocity: Int) {
        // Ensure the instrument entry exists in activeSounds
        if activeSounds[instrument] == nil {
            activeSounds[instrument] = [:]
        }
        
        // Stop any currently playing sound for this instrument/note
        stop(instrument: instrument, note: note)
        
        // Create a sound based on the note
        let sound = createSoundForNote(note: note, velocity: velocity)
        
        // Store the sound for later stopping
        activeSounds[instrument]?[note] = sound
        
        // Play the sound
        sound.play()
        print("Playing note \(note) with velocity \(velocity) on instrument \(instrument)")
    }
    
    // Helper method to create a sound for a note
    private func createSoundForNote(note: Int, velocity: Int) -> NSSound {
        // Use simple system beep sound - guaranteed to play on all Macs
        let soundName: NSSound.Name
        
        // Map notes to different system sounds - using standard system sounds
        switch note % 12 {
        case 0: soundName = "Ping"
        case 1: soundName = "Basso"
        case 2: soundName = "Tink"
        case 3: soundName = "Pop"
        case 4: soundName = "Ping"  // Repeat some sounds since macOS doesn't have 12 distinct sounds
        case 5: soundName = "Basso"
        case 6: soundName = "Tink"
        case 7: soundName = "Pop"
        case 8: soundName = "Ping"
        case 9: soundName = "Basso"
        case 10: soundName = "Tink"
        case 11: soundName = "Pop"
        default: soundName = "Ping"
        }
        
        // Create and configure the sound
        let sound = NSSound(named: soundName)!
        sound.volume = Float(min(100, max(60, velocity))) / 100.0
        
        return sound
    }
    
    // EFFECTS: stops playback of the given instrument
    func stop(instrument: Int, note: Int) {
        // Check if we have a sound for this instrument and note
        if let sound = activeSounds[instrument]?[note] {
            // Stop the sound
            sound.stop()
            
            // Remove from active sounds
            activeSounds[instrument]?[note] = nil
            print("Stopped note \(note) on instrument \(instrument)")
        }
    }
    
    // MODIFIES: this
    // EFFECTS:  sets up the channels for this MidiSynth
    private func setupChannels() {
        channels = []
        channelMap = [:]
        for i in 0..<16 { // MIDI has 16 channels
            channels.append(ChannelData(channel: i, num: i))
        }
    }
    
    // MODIFIES: this
    // EFFECTS: sets up the synthesizer - simplified for direct sound playback
    private func setupSynthesizer() {
        // Using system sounds instead of synthesizer
        // No initialization needed
        print("Using system sounds for audio playback")
    }
    
    // EFFECTS: returns the channel associated with the given instrument
    private func getChannelData(instrument: Int) -> ChannelData {
        if let channelData = channelMap[instrument] {
            return channelData
        } else {
            let channelData = getSpecialisedChannel(channelMap.count)
            channelMap[instrument] = channelData
            return channelData
        }
    }
    
    // EFFECTS: return the channel at the given index
    func getSpecialisedChannel(_ index: Int) -> ChannelData {
        // Create new channels as needed
        while channels.count <= index {
            let newChannel = ChannelData(channel: channels.count, num: channels.count)
            channels.append(newChannel)
        }
        return channels[index]
    }
}
