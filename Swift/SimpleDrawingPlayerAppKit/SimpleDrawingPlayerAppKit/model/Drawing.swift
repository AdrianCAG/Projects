//
//  Drawing.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//

import AppKit



class Drawing: NSView {
    static private let MUSIC_LINES_SPACE = 30
    
    private var shapes: [Shape]
    private var playLineColumn: Int = 0
    
    override init(frame frameRect: NSRect) {
        shapes = []
        super.init(frame: frameRect)
        self.layer?.backgroundColor = NSColor.white.cgColor
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        shapes = []
        super.init(coder: coder)
        self.layer?.backgroundColor = NSColor.white.cgColor
        self.wantsLayer = true
    }
    
    // getters
    func getShapes() -> [Shape] { return self.shapes }
    func getPlayLineColumn() -> Int { return self.playLineColumn }
    
    // setters
    func setPlayLineColumn(_ plc: Int) { playLineColumn = plc }
    
    // EFFECTS: return true if the given Shape s is contained in Drawing
    func containsShape(_ s: Shape) -> Bool {
        return shapes.contains { $0 === s }
    }
    
    // paintComponent
    // EFFECTS: paints grid, playback line, and all figures in drawing
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current else { return }
        
        drawHorizontalNotesLines(context)
        
        for shape in shapes {
            shape.draw(context)
        }
    }
    
    // EFFECTS: draws grid with lines GRIDSPACE apart, and draws red line at its current position
    private func drawHorizontalNotesLines(_ g: NSGraphicsContext) {
        let context = g.cgContext
        context.saveGState() // Save the current graphics state
        
        context.setStrokeColor(NSColor(calibratedRed: 227/255, green: 227/255, blue: 227/255, alpha: 1.0).cgColor)
        
        for y in stride(from: Drawing.MUSIC_LINES_SPACE, to: Int(bounds.height), by: Drawing.MUSIC_LINES_SPACE) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: Int(bounds.width), y: y))
            context.strokePath()
        }
        
        if playLineColumn > 0 && playLineColumn < Int(bounds.width) {
            context.setStrokeColor(NSColor.red.cgColor)
            context.move(to: CGPoint(x: playLineColumn, y: 0))
            context.addLine(to: CGPoint(x: playLineColumn, y: Int(bounds.height)))
            context.strokePath()
        }
        
        context.restoreGState() // Restore the saved graphics state
    }
    
    // MODIFIES: this
    // EFFECTS:  adds the given shape to the drawing
    func addShape(_ shape: Shape) {
        shapes.append(shape)
    }
    
    // MODIFIES: this
    // EFFECTS:  removes shape from the drawing
    func removeShape(_ shape: Shape) {
        if let index = shapes.firstIndex(where: { $0 === shape }) {
            shapes.remove(at: index)
        }
        self.needsDisplay = true
    }
    
    // EFFECTS: returns the Shape at a given Point in Drawing, if any
    func getShapesAtPoint(_ point: NSPoint) -> Shape? {
        for shape in shapes {
            if shape.contains(point: point) {
                return shape
            }
        }
        return nil
    }
    
    // EFFECTS: returns all Shapes at given column corresponding to an x-coordinate
    func getShapesAtColumn(_ x: Int) -> [Shape] {
        var shapesAtColumn: [Shape] = []
        for shape in shapes {
            if shape.containsX(x) {
                shapesAtColumn.append(shape)
            }
        }
        return shapesAtColumn
    }
}
