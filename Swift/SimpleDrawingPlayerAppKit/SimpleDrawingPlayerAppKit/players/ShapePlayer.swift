//
//  ShapePlayer.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//

import Foundation




class ShapePlayer: NSObject {
    private var shape: Shape
    private var drawing: Drawing
    private var t: Timer?
    private var playingColumn: Int
    
    init(_ drawing: Drawing, _ shape: Shape, _ t: Timer?) {
        self.shape = shape
        self.drawing = drawing
        self.t = t
        playingColumn = 0
    }
    
    func getTimer() -> Timer? {
        if let timer = t  {
            return timer
        }
        
        return nil
    }
    
    // Sets the timer reference after initialization
    func setTimer(_ timer: Timer) {
        t = timer
    }
    
    // MODIFIES: this
    // EFFECTS:  plays shape(s) in the current column, repaints, increments
    //           column, and stops if done
    @objc func actionPerformed() {
        playColumn()
        incrementColumn()
        stopPlayingWhenDone()
    }
    
    // MODIFIES: this
    // EFFECTS:  moves current x-column to the next column
    private func incrementColumn() {
        // Increment by 3 instead of 1 for faster playback
        playingColumn += 10
    }
    
    // MODIFIES: this
    // EFFECTS:  shapes in the current playingColumn are selected and played
    //           the frame is repainted
    private func playColumn() {
        shape.setPlayLineCoord(playingColumn)
        shape.selectAndPlay()
        drawing.needsDisplay = true
    }
    
    // MODIFIES: this
    // EFFECTS:  stops t when the playingColumn is past the edge of the frame
    private func stopPlayingWhenDone() {
        if playingColumn > shape.getWidth() {
            shape.unselectAndStopPlaying()
            shape.setPlayLineCoord(0)
            drawing.needsDisplay = true
            t?.invalidate()
        }
    }
}
