//
//  ChannelData.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import Foundation




class ChannelData {
    private var channel: Int
    
    private var velocity: Int
    private var pressure: Int
    private var bend: Int
    private var reverb: Int
    private var num: Int
    
    // getters
    func getChannel() -> Int { return channel }
    
    init(channel: Int, num: Int) {
        self.channel = channel
        self.num = num
        self.velocity = 64
        self.pressure = 64
        self.bend = 64
        self.reverb = 64
    }
}
