//
//  MVCPatternAppApp.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

@main
struct MVCPatternAppApp: App {
    // Create the TaskController that will be shared across the app
    @StateObject private var taskController = TaskController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskController) // Inject the TaskController into the environment
        }
    }
}
