//
//  SortBooksView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct SortBooksView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: BookLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sort By")) {
                    ForEach(SortOption.allCases) { option in
                        SortOptionRow(
                            title: option.rawValue,
                            isSelected: viewModel.sortOption == option,
                            isAscending: viewModel.sortAscending
                        ) {
                            viewModel.setSortOption(option)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                Section(header: Text("Sort Order")) {
                    Button(action: {
                        viewModel.sortAscending = true
                        viewModel.updateFilteredBooks()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Ascending")
                            
                            Spacer()
                            
                            if viewModel.sortAscending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Button(action: {
                        viewModel.sortAscending = false
                        viewModel.updateFilteredBooks()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Descending")
                            
                            Spacer()
                            
                            if !viewModel.sortAscending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Sort Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - SortOptionRow

struct SortOptionRow: View {
    let title: String
    let isSelected: Bool
    let isAscending: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
        }
    }
}

// MARK: - Preview

struct SortBooksView_Previews: PreviewProvider {
    static var previews: some View {
        SortBooksView(viewModel: BookLibraryViewModel())
    }
}
