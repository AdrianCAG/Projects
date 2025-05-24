//
//  ShapeTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit



class ShapeTool: Tool {
    private var shape: Shape?
    private var newShapeStart: NSPoint?
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Shape")
    }
    

    
    // EFFECTS: creates new shape, adds to drawing
    override func mousePressedInDrawingArea(e: NSEvent) {
        let convertedPoint = getEditor().convertPointToDrawingCoordinates(e.locationInWindow)
        newShapeStart = convertedPoint
        shape = Shape(convertedPoint, getEditor().getMidiSynth())
        getEditor().addToDrawing(shape!)
    }
    
    // EFFECTS: sets shape bounds to wherever mouse is now
    override func mouseDraggedInDrawingArea(e: NSEvent) {
        if let currentShape = shape, let start = newShapeStart {
            let end = getEditor().convertPointToDrawingCoordinates(e.locationInWindow)
            
            // Calculate the actual top-left and bottom-right points regardless of drag direction
            let topLeftX = min(start.x, end.x)
            let topLeftY = min(start.y, end.y)
            let bottomRightX = max(start.x, end.x)
            let bottomRightY = max(start.y, end.y)
            
            // Create a new shape with the correct dimensions
            let topLeft = NSPoint(x: topLeftX, y: topLeftY)
            let bottomRight = NSPoint(x: bottomRightX, y: bottomRightY)
            
            // Update the shape's position and size
            currentShape.setPosition(topLeft)
            currentShape.setBounds(bottomRight: bottomRight)
        }
    }
    
    // Default implementations from base class are used for:
    // mouseClickedInDrawingArea, mouseReleasedInDrawingArea, activate, deactivate
}

