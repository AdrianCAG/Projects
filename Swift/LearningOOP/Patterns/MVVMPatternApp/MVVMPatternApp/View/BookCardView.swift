//
//  BookCardView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct BookCardView: View {
    // MARK: - Properties
    
    let book: Book
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // Book cover image or placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorForGenre(book.genre))
                    .frame(height: 120)
                
                VStack {
                    Image(systemName: book.genre.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text(book.genre.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(book.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                // Author
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer(minLength: 4)
                
                // Reading status indicator
                HStack {
                    Image(systemName: book.status.iconName)
                        .foregroundColor(.blue)
                    
                    Text(book.status.rawValue)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    // Format indicator
                    Image(systemName: book.format.iconName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    // MARK: - Helper Methods
    
    /// Returns a color based on the book genre for the cover background
    private func colorForGenre(_ genre: BookGenre) -> Color {
        switch genre {
        case .fiction:
            return Color.blue
        case .nonFiction:
            return Color.orange
        case .fantasy:
            return Color.purple
        case .sciFi:
            return Color.green
        case .mystery:
            return Color.red
        case .thriller:
            return Color.pink
        case .biography:
            return Color.yellow
        case .history:
            return Color.gray
        case .selfHelp:
            return Color.teal
        case .other:
            return Color.indigo
        }
    }
}

// MARK: - Preview

struct BookCardView_Previews: PreviewProvider {
    static var previews: some View {
        BookCardView(book: Book.sampleBooks[0])
            .frame(width: 160, height: 240)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
