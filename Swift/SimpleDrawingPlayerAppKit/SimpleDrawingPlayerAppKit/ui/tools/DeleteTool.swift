//
//  DeleteTool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit




class DeleteTool: Tool {
    private var shapeToDelete: Shape?
    
    init(editor: DrawingEditor, parent: NSView) {
        super.init(editor: editor, parent: parent, title: "Delete")
    }
    

    
    override func mousePressedInDrawingArea(e: NSEvent) {
        deleteShapeAt(e.locationInWindow)
    }
    
    override func mouseDraggedInDrawingArea(e: NSEvent) {
        deleteShapeAt(e.locationInWindow)
    }
    
    private func deleteShapeAt(_ p: NSPoint) {
        // We don't need to convert coordinates here because getShapeInDrawing already does the conversion
        if let toRemove = getEditor().getShapeInDrawing(point: p) {
            self.shapeToDelete = toRemove
            toRemove.unselectAndStopPlaying()
            getEditor().removeFromDrawing(toRemove)
        }
    }
    
    override func mouseClickedInDrawingArea(e: NSEvent) {
        // Not implemented
    }
    
    override func mouseReleasedInDrawingArea(e: NSEvent) {
        // Not implemented
    }
    
    override func activate() {
        button.state = .on
    }
    
    override func deactivate() {
        button.state = .off
    }
}
