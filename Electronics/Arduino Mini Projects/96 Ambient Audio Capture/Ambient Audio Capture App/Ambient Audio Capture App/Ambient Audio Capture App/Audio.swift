//
//  Audio.swift
//  Ambient Audio Capture App
//
//  Created by Adrian on 10/3/25.
//

import Foundation





// MARK: - Supporting Types
struct SerialPort: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let name: String
}

struct AudioDevice: Identifiable, Hashable {
    let id: String
    let name: String
}

enum AudioFormat: String, CaseIterable, Identifiable {
    case wav = "WAV"
    case m4a = "M4A"
    case aiff = "AIFF"
    
    var id: String { rawValue }
    var fileExtension: String { rawValue.lowercased() }
}
