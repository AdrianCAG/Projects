//
//  EmptyLibraryView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct EmptyLibraryView: View {
    // MARK: - Properties
    
    let isFiltered: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text(isFiltered ? "No Books Match Your Filters" : "Your Library is Empty")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(isFiltered ? 
                "Try changing your filter settings to see more books." : 
                "Start adding books to your personal collection.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if isFiltered {
                Button(action: {
                    // This will be handled by the parent view through viewModel
                }) {
                    Text("Clear Filters")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct EmptyLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyLibraryView(isFiltered: false)
                .previewDisplayName("Empty Library")
            
            EmptyLibraryView(isFiltered: true)
                .previewDisplayName("Filtered Empty")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
