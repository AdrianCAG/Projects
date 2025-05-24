//
//  ResizeTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit



class ResizeTool: Tool {
    private var shapeToResize: Shape?
    private var dragStartPoint: NSPoint?
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Resize")
    }
    

    
    override func mousePressedInDrawingArea(e: NSEvent) {
        let clickPoint = e.locationInWindow
        shapeToResize = getEditor().getShapeInDrawing(point: clickPoint)
        dragStartPoint = getEditor().convertPointToDrawingCoordinates(clickPoint)
    }
    
    override func mouseDraggedInDrawingArea(e: NSEvent) {
        if let shape = shapeToResize {
            let current = getEditor().convertPointToDrawingCoordinates(e.locationInWindow)
            shape.setBounds(bottomRight: current)
        }
    }
    
    // Default implementations from base class are used for:
    // mouseClickedInDrawingArea, mouseReleasedInDrawingArea, activate, deactivate
}
