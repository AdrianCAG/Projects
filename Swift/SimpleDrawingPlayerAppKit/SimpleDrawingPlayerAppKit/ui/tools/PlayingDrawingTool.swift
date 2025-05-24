//
//  PlayingDrawingTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit



class PlayDrawingTool: Tool {
    private var timer: Timer?
    private var player: DrawingPlayer?
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Play Drawing")
    }
    
    // EFFECTS: start playing the drawing
    override func mousePressedInDrawingArea(e: NSEvent) {
        // Always ensure any previous playback is fully stopped
        stopPlaying()
        
        // Reset the playback line
        getEditor().getCurrentDrawing().setPlayLineColumn(0)
        getEditor().getCurrentDrawing().needsDisplay = true
        
        // Create a new timer with a short interval for smooth playback
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common) // Ensures timer runs even during UI interactions
    }
    
    @objc private func timerAction(_ t: Timer) {
        // Create the player only once and reuse it
        if player == nil {
            player = DrawingPlayer(getEditor().getCurrentDrawing(), t)
        }
        
        // Update the drawing reference in case it changed
        if let player = player {
            player.actionPerformed()
        }
    }
    
    // EFFECTS: stop playing the drawing
    private func stopPlaying() {
        if let currentTimer = timer {
            currentTimer.invalidate()
            timer = nil
            
            // Reset playback line
            getEditor().getCurrentDrawing().setPlayLineColumn(0)
            getEditor().getCurrentDrawing().needsDisplay = true
            
            // Stop all shapes from playing
            for shape in getEditor().getCurrentDrawing().getShapes() {
                shape.unselectAndStopPlaying()
            }
            
            // Clear player reference
            player = nil
        }
    }
    
    // Default implementations from base class are used for:
    // mouseDraggedInDrawingArea, mouseClickedInDrawingArea, mouseReleasedInDrawingArea, activate, deactivate
}
