//
//  Tool.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/21/25.
//

import AppKit




class Tool: NSObject {
    private var editor: DrawingEditor
    var button: NSButton
    
    init(editor: DrawingEditor, parent: NSView, title: String) {
        self.editor = editor
        
        // Create the button that activates this tool
        self.button = NSButton(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
        self.button.title = title
        self.button.bezelStyle = .rounded
        parent.addSubview(self.button)
        
        super.init()
        
        self.button.target = self
        self.button.action = #selector(buttonPressed)
    }
    
    @objc func buttonPressed() {
        editor.setActiveTool(self)
    }
    
    // EFFECTS: called whenever the tool is activated
    func activate() {
        button.state = .on
    }
    
    // EFFECTS: called whenever the tool is deactivated
    func deactivate() {
        button.state = .off
    }
    
    // EFFECTS: called whenever the mouse is clicked in the drawing area
    func mouseClickedInDrawingArea(e: NSEvent) {
        // Default implementation does nothing
    }
    
    // EFFECTS: called whenever the mouse is pressed in the drawing area
    func mousePressedInDrawingArea(e: NSEvent) {
        // Default implementation does nothing
    }
    
    // EFFECTS: called whenever the mouse is released in the drawing area
    func mouseReleasedInDrawingArea(e: NSEvent) {
        // Default implementation does nothing
    }
    
    // EFFECTS: called whenever the mouse is dragged in the drawing area
    func mouseDraggedInDrawingArea(e: NSEvent) {
        // Default implementation does nothing
    }
    
    // Getter for editor
    func getEditor() -> DrawingEditor {
        return editor
    }
    
    // Getter for button
    func getButton() -> NSButton {
        return button
    }
}
