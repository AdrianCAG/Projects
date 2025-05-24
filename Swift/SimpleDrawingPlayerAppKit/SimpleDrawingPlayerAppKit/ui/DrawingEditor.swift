//
//  DrawingEditor.swift
//  SimpleDrawingPlayer - Observer Pattern
//
//  Created by Adrian on 5/20/25.
//

import AppKit
import AudioToolbox

class DrawingEditor: NSWindow {
    static let WIDTH = 1000
    static let HEIGHT = 700
    
    private var midiSynth: MidiSynth
    
    private var tools: [Tool] = []
    private var activeTool: Tool?
    
    private var currentDrawing: Drawing
    private var toolArea: NSView
    
    init() {
        // Setup size and position
        let contentRect = NSRect(x: 0, y: 0, width: DrawingEditor.WIDTH, height: DrawingEditor.HEIGHT)
        
        // Initialize fields
        self.midiSynth = MidiSynth()
        self.currentDrawing = Drawing(frame: NSRect(x: 0, y: 0, width: DrawingEditor.WIDTH, height: DrawingEditor.HEIGHT - 100))
        self.toolArea = NSView(frame: NSRect(x: 0, y: 0, width: DrawingEditor.WIDTH, height: 100))
        
        // Initialize the window
        super.init(contentRect: contentRect,
                    styleMask: [.titled, .closable, .miniaturizable, .resizable],
                    backing: .buffered,
                    defer: false)
        
        self.title = "Drawing Player"
        self.center()
        self.makeKeyAndOrderFront(nil)
        
        // Setup the drawing area and tools
        initializeGraphics()
        initializeSound()
        initializeInteraction()
    }
    
    // getters
    func getCurrentDrawing() -> Drawing { return currentDrawing }
    func getMidiSynth() -> MidiSynth { return midiSynth }
    
    // MODIFIES: this
    // EFFECTS:  initializes mouse event handling for drawing
    private func initializeInteraction() {
        // Set up the drawing area to receive mouse events
        let eventMask: NSEvent.EventTypeMask = [.leftMouseDown, .leftMouseUp, .leftMouseDragged]
        NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
            if let self = self, let contentView = self.contentView {
                let point = contentView.convert(event.locationInWindow, from: nil)
                
                if self.currentDrawing.frame.contains(point) {
                    switch event.type {
                    case .leftMouseDown:
                        self.handleMousePressed(event)
                    case .leftMouseUp:
                        self.handleMouseReleased(event)
                    case .leftMouseDragged:
                        self.handleMouseDragged(event)
                    default:
                        break
                    }
                }
            }
            return event
        }
    }
    
    // MODIFIES: this
    // EFFECTS:  initializes this DrawingEditor's midisynth field, then calls open() on it
    private func initializeSound() {
        midiSynth.open()
    }
    
    // MODIFIES: this
    // EFFECTS:  sets up the UI components including drawing area and tools
    private func initializeGraphics() {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: DrawingEditor.WIDTH, height: DrawingEditor.HEIGHT))
        
        // Position the tool area at the bottom
        toolArea.frame = NSRect(x: 0, y: 0, width: DrawingEditor.WIDTH, height: 100)
        
        // Position the drawing area above the tool area
        currentDrawing.frame = NSRect(x: 0, y: 100, width: DrawingEditor.WIDTH, height: DrawingEditor.HEIGHT - 100)
        
        // Add both to the content view
        contentView.addSubview(toolArea)
        contentView.addSubview(currentDrawing)
        
        // Create the tools
        createTools()
        
        self.contentView = contentView
    }
    
    // MODIFIES: this
    // EFFECTS:  adds given Shape to currentDrawing
    func addToDrawing(_ shape: Shape) {
        currentDrawing.addShape(shape)
    }
    
    // MODIFIES: this
    // EFFECTS:  removes given Shape from currentDrawing
    func removeFromDrawing(_ shape: Shape) {
        currentDrawing.removeShape(shape)
    }
    
    // EFFECTS: if activeTool != null, then mousePressedInDrawingArea is invoked on activeTool
    private func handleMousePressed(_ e: NSEvent) {
        if let tool = activeTool {
            tool.mousePressedInDrawingArea(e: e)
        }
        currentDrawing.needsDisplay = true
        
        
    }
    
    // EFFECTS: if activeTool != null, then mouseReleasedInDrawingArea is invoked on activeTool
    private func handleMouseReleased(_ e: NSEvent) {
        if let tool = activeTool {
            tool.mouseReleasedInDrawingArea(e: e)
        }
        currentDrawing.needsDisplay = true
    }
    
    // EFFECTS: if activeTool != null, then mouseClickedInDrawingArea is invoked on activeTool
    private func handleMouseClicked(_ e: NSEvent) {
        if let tool = activeTool {
            tool.mouseClickedInDrawingArea(e: e)
        }
        currentDrawing.needsDisplay = true
    }
    
    // EFFECTS: if activeTool != null, then mouseDraggedInDrawingArea is invoked on activeTool
    private func handleMouseDragged(_ e: NSEvent) {
        if let tool = activeTool {
            tool.mouseDraggedInDrawingArea(e: e)
        }
        currentDrawing.needsDisplay = true
    }
    
    // MODIFIES: this
    // EFFECTS:  sets the given tool as the activeTool
    func setActiveTool(_ aTool: Tool) {
        if let tool = activeTool {
            tool.deactivate()
        }
        
        aTool.activate()
        activeTool = aTool
    }
    
    // EFFECTS: return shapes at given point at the currentDrawing
    func getShapeInDrawing(point: NSPoint) -> Shape? {
        let pointInDrawing = convertPointToDrawingCoordinates(point)
        return currentDrawing.getShapesAtPoint(pointInDrawing)
    }
    
    // EFFECTS: converts window coordinates to drawing view coordinates
    func convertPointToDrawingCoordinates(_ windowPoint: NSPoint) -> NSPoint {
        guard let contentView = self.contentView else {
            return windowPoint
        }
        
        // First convert from window coordinates to content view coordinates
        let pointInContentView = contentView.convert(windowPoint, from: nil)
        
        // Then convert from content view coordinates to drawing view coordinates
        return currentDrawing.convert(pointInContentView, from: contentView)
    }
    
    // MODIFIES: this
    // EFFECTS:  creates all tools and adds them to the tool area
    private func createTools() {
        let buttonHeight = 30
        let buttonWidth = 120
        let padding = 10
        
        // Initialize all the tools
        let rectTool = ShapeTool(editor: self, parent: toolArea)
        tools.append(rectTool)
        
        let moveTool = MoveTool(editor: self, parent: toolArea)
        tools.append(moveTool)
        
        let resizeTool = ResizeTool(editor: self, parent: toolArea)
        tools.append(resizeTool)
        
        let deleteTool = DeleteTool(editor: self, parent: toolArea)
        tools.append(deleteTool)
        
        let playShapeTool = PlayShapeTool(editor: self, parent: toolArea)
        tools.append(playShapeTool)
        
        let playDrawingTool = PlayDrawingTool(editor: self, parent: toolArea)
        tools.append(playDrawingTool)
        
        // Calculate how many buttons per row
        let buttonsPerRow = min(6, tools.count)
        let totalButtonWidth = buttonsPerRow * buttonWidth
        let totalPadding = (buttonsPerRow - 1) * padding
        let startX = (DrawingEditor.WIDTH - totalButtonWidth - totalPadding) / 2
        
        // Position the tools horizontally in the center
        var xPosition = startX
        let yPosition = (Int(toolArea.frame.height) - buttonHeight) / 2  // Center vertically
        
        for (index, _) in tools.enumerated() {
            if let button = toolArea.subviews[index] as? NSButton {
                button.frame = NSRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
                button.bezelStyle = .rounded
                button.font = NSFont.systemFont(ofSize: 12.0)
                button.isBordered = true
                button.setButtonType(.pushOnPushOff)
                xPosition += buttonWidth + padding
            }
        }
        
        // Set the initial active tool
        setActiveTool(rectTool)
    }
}
