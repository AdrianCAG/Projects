//
//  PlayShapeTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit



class PlayShapeTool: Tool {
    // Array to track all active shape players
    private var activeShapes: [(shape: Shape, timer: Timer)] = []
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Play Shape")
    }
    
    // EFFECTS: handles mouse press on a shape - restarts animation if clicked again
    override func mousePressedInDrawingArea(e: NSEvent) {
        let clickPoint = e.locationInWindow
        
        if let shapeToPlay = getEditor().getShapeInDrawing(point: clickPoint) {
            // Cancel any existing animation on this shape
            cancelExistingAnimation(shapeToPlay)
            
            // Play the shape immediately
            playShape(shapeToPlay)
        }
    }
    
    // Cancel an existing animation for a shape
    private func cancelExistingAnimation(_ shape: Shape) {
        // Find and remove any existing animations for this shape
        if let index = activeShapes.firstIndex(where: { $0.shape === shape }) {
            activeShapes[index].timer.invalidate()
            activeShapes.remove(at: index)
        }
    }
    
    // Play a shape immediately
    private func playShape(_ shape: Shape) {
        // Reset and select the shape
        shape.setPlayLineCoord(0)
        
        // First stop any sound that might be playing for this shape
        shape.unselectAndStopPlaying()
        
        // Select and play sound for the shape
        shape.selectAndPlay()
        
        // Create a timer for the animation
        let timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateAnimation(_:)), userInfo: shape, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        
        // Add to active shapes array
        activeShapes.append((shape: shape, timer: timer))
        
        // Force a redraw
        getEditor().getCurrentDrawing().needsDisplay = true
    }
    
    @objc private func updateAnimation(_ t: Timer) {
        guard let shape = t.userInfo as? Shape else { return }
        
        // Increment the playline position
        let currentPosition = shape.getPlayLineCoord()
        let newPosition = currentPosition + 10 // Move faster for better visual feedback
        
        // Update the play line position
        shape.setPlayLineCoord(newPosition)
        
        // Redraw the shape
        getEditor().getCurrentDrawing().needsDisplay = true
        
        // Check if we've reached the end of the shape
        if newPosition > shape.getWidth() {
            // Animation is complete, reset
            shape.unselectAndStopPlaying()
            shape.setPlayLineCoord(0)
            getEditor().getCurrentDrawing().needsDisplay = true
            
            // Remove from active shapes
            t.invalidate()
            if let index = activeShapes.firstIndex(where: { $0.shape === shape }) {
                activeShapes.remove(at: index)
            }
        }
    }
    
    // When tool is deactivated, stop all animations
    override func deactivate() {
        super.deactivate()
        
        // Stop all active animations
        for shapePair in activeShapes {
            shapePair.timer.invalidate()
            shapePair.shape.unselectAndStopPlaying()
            shapePair.shape.setPlayLineCoord(0)
        }
        
        activeShapes.removeAll()
        getEditor().getCurrentDrawing().needsDisplay = true
    }
}
