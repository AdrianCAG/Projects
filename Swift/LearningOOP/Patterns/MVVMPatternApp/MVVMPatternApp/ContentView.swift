//
//  ContentView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct ContentView: View {
    // Create a shared instance of the ViewModel
    @StateObject private var libraryViewModel = BookLibraryViewModel()
    
    var body: some View {
        // Use the BookLibraryView as the main view, passing our view model
        BookLibraryView(viewModel: libraryViewModel)
    }
}

#Preview {
    ContentView()
}
