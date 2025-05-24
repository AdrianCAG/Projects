//
//  MoveTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit




class MoveTool: Tool {
    private var shapeToMove: Shape?
    private var start: NSPoint?
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Move")
    }
    

    override func mousePressedInDrawingArea(e: NSEvent) {
        let clickPoint = e.locationInWindow
        shapeToMove = getEditor().getShapeInDrawing(point: clickPoint)
        start = getEditor().convertPointToDrawingCoordinates(clickPoint)
    }
    
    override func mouseDraggedInDrawingArea(e: NSEvent) {
        if let shape = shapeToMove, let startPoint = start {
            let current = getEditor().convertPointToDrawingCoordinates(e.locationInWindow)
            
            // Calculate movement distance
            let dx = Int(current.x - startPoint.x)
            let dy = Int(current.y - startPoint.y)
            
            // Only move if there's actual movement (prevents jittering)
            if dx != 0 || dy != 0 {
                // Perform the move
                shape.move(dx: dx, dy: dy)
                
                // Update start point for next drag event
                start = current
                
                // Force redraw to make movement smoother
                getEditor().getCurrentDrawing().needsDisplay = true
            }
        }
    }
    
    // Default implementations from base class are used for:
    // mouseClickedInDrawingArea, mouseReleasedInDrawingArea, activate, deactivate
}

