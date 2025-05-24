//
//  Shape.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//


import AppKit




class Shape {
    static let PLAYING_COLOR = NSColor(red: 230/255, green: 158/255, blue: 60/255, alpha: 1.0)
    
    private var x: Int
    private var y: Int
    private var width: Int
    private var height: Int
    
    private var selected: Bool = false
    private var soundProducer: SoundProducer?
    private var instrument: Int = 0
    private var playLineCoord: Int = 0
    
    init(_ x: Int, _ y: Int, _ w: Int, _ h: Int) {
        self.x = x
        self.y = y
        width = w
        height = h
    }
    
    convenience init(_ topLeft: NSPoint, _ soundProducer: SoundProducer) {
        self.init(Int(topLeft.x), Int(topLeft.y), 0, 0)
        selected = false
        self.soundProducer = soundProducer
        instrument = 0
        playLineCoord = 0
    }
    
    
    // Set sound producer after initialization if needed
    func setSoundProducer(_ producer: SoundProducer) {
        self.soundProducer = producer
    }
    
    // getters
    func getWidth() -> Int { return width }
    func getXCoord() -> Int { return x }
    func getYCoord() -> Int { return y }
    func getHeight() -> Int { return height }
    func isSelected() -> Bool { return selected }
    
    // setters
    func setPlayLineCoord(_ playLineCoord: Int) {
        self.playLineCoord = playLineCoord
    }
    
    func getPlayLineCoord() -> Int {
        return self.playLineCoord
    }
    
    func setPosition(_ position: NSPoint) {
        self.x = Int(position.x)
        self.y = Int(position.y)
    }
    
    // EFFECTS: return true if the given x value is within the bounds of the Shape
    func containsX(_ x: Int) -> Bool {
        return (self.x <= x) && (x <= self.x + width)
    }
    
    // EFFECTS: return true if the given y value is within the bounds of the Shape
    func containsY(_ y: Int) -> Bool {
        return (self.y <= y) && (y <= self.y + height)
    }
    
    // EFFECTS: return true if the given Point (x,y) is contained within the bounds of this Shape
    func contains(point: NSPoint) -> Bool {
        let point_x = Int(point.x)
        let point_y = Int(point.y)
        
        return containsX(point_x) && containsY(point_y)
    }
    
    // REQUIRES: the x,y coordinates of the Point are larger than the x,y coordinates of the shape
    // MODIFIES: this
    // EFFECTS:  sets the bottom right corner of this Shape to the given Point
    func setBounds(bottomRight: NSPoint) {
        width = Int(bottomRight.x) - x
        height = Int(bottomRight.y) - y
    }
    
    // EFFECTS: draws this Shape on the SimpleDrawingPlayer, if the shape is selected, Shape is filled in
    //          else, Shape is unfilled (white)
    func draw(_ g: NSGraphicsContext) {
        let context = g.cgContext
        
        if selected {
            context.setFillColor(Shape.PLAYING_COLOR.cgColor)
        } else {
            context.setFillColor(NSColor.white.cgColor)
        }
        
        context.fill(CGRect(x: x, y: y, width: width, height: height))
        context.setStrokeColor(NSColor.black.cgColor)
        context.stroke(CGRect(x: x, y: y, width: width, height: height))
        
        if playLineCoord > 0 && playLineCoord < width {
            context.setStrokeColor(NSColor.red.cgColor)
            context.move(to: CGPoint(x: x + playLineCoord, y: y))
            context.addLine(to: CGPoint(x: x + playLineCoord, y: y + height))
            context.strokePath()
        }
    }
    
    // MODIFIES: this
    // EFFECTS: adds dx to the shapes x coordinate, and dy to the shapes y coordinate.
    //          If the sound associated with the new y-coordinate is different, play the new sound
    func move(dx: Int, dy: Int) {
        let noteChanges = coordToNote(y) != coordToNote(y + dy)
        
        if noteChanges {
            stopPlaying()
        }
        
        x += dx
        y += dy
        
        if noteChanges {
            play()
        }
    }
    
    
    // MODIFIES: this
    // EFFECTS:  selects this Shape, plays associated sound
    func selectAndPlay() {
        if !selected {
            selected = true
            play()
        }
    }
    
    // MODIFIES: this
    // EFFECTS:  unselects this Shape, stops playing associated sound
    func unselectAndStopPlaying() {
        if selected {
            selected = false
            stopPlaying()
        }
    }
    
    // EFFECTS: starts playing this Shape, where sound is dependent on the area/coordinates of the Shape
    private func play() {
        guard let soundProducer = soundProducer else { return }
        let volume = areaToVelocity(width * height)
        soundProducer.play(instrument: instrument, note: coordToNote(y), velocity: volume)
    }
    
    // EFFECTS: stops playing this Shape
    private func stopPlaying(){
        guard let soundProducer = soundProducer else { return }
        soundProducer.stop(instrument: instrument, note: coordToNote(y))
    }
    
    // EFFECTS: return a velocity based on the area of a Shape
    //          The only meaningful velocities are between 0 and 127
    //          Velocities less than 60 are too quiet to be heard
    private func areaToVelocity(_ area: Int) -> Int {
        return max(60, min(127, area / 30))
    }
    
    // EFFECTS: maps a given integer to a valid associated note
    private func coordToNote(_ y: Int) -> Int {
        return 70 - y / 12
    }
    
}
