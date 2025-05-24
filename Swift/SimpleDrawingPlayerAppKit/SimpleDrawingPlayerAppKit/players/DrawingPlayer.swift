//
//  DrawingPlayer.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//

import Foundation




class DrawingPlayer: NSObject {
    private var drawing: Drawing
    private var timer: Timer
    private var playingColumn: Int
    
    private var lastColumnPlayed: [Shape]
    private var shapesInColumn: [Shape]
    
    // EFFECTS: constructs a DrawingPlayer
    init(_ drawing: Drawing, _ timer: Timer) {
        self.drawing = drawing
        self.timer = timer
        playingColumn = 0
        self.lastColumnPlayed = []
        self.shapesInColumn = []
    }
    
    // MODIFIES: this
    // EFFECTS:  plays shapes in current column, repaints, increments column, stops if done
    //           this class is the listener for the timer object, and this method is what the timer calls
    //           each time through its loop.
    @objc func actionPerformed() {
        selectAndPlayShapes()
        drawRedLine()
        incrementColumn()
        stopPlayingWhenDone()
    }
    
    // MODIFIES: this
    // EFFECTS:  moves current x-column to next column; updates figures
    private func incrementColumn() {
        // Increment by 3 instead of 1 for faster playback
        playingColumn += 10
        lastColumnPlayed = shapesInColumn
    }
    
    // MODIFIES: this
    // EFFECTS:  moves playback line to playingColumn to trigger sound and repaint
    private func drawRedLine() {
        drawing.setPlayLineColumn(playingColumn)
        drawing.needsDisplay = true // the Swift equivalent to Java's repaint()
    }
    
    // MODIFIES: this
    // EFFECTS:  calls Timer.stop() when playingColumn is past the edge of the frame
    private func stopPlayingWhenDone() {
        if playingColumn > DrawingEditor.WIDTH {
            timer.invalidate()
        }
    }
    
    // MODIFIES: this
    // EFFECTS:  selects and plays shape(s) in the playingColumn
    private func selectAndPlayShapes() {
        shapesInColumn = drawing.getShapesAtColumn(playingColumn)
        stopPlayingCompletedShapes()
        startPlayingNewShapes()
    }
    
    private func startPlayingNewShapes() {
        for shape in shapesInColumn {
            if !lastColumnPlayed.contains(where: { $0 === shape }) {
                shape.selectAndPlay()
            }
        }
    }
    
    private func stopPlayingCompletedShapes() {
        for shape in lastColumnPlayed {
            if !shapesInColumn.contains(where: { $0 === shape }) {
                shape.unselectAndStopPlaying()
            }
        }
    }
}
