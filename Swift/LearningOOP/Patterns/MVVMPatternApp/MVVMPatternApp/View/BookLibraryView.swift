//
//  BookLibraryView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct BookLibraryView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: BookLibraryViewModel
    @State private var showingAddBookSheet = false
    @State private var showingFilterSheet = false
    @State private var showingSortSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter and search bar
                HStack {
                    TextField("Search books...", text: Binding(
                        get: { self.viewModel.searchQuery },
                        set: { self.viewModel.setSearchQuery($0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.title2)
                    }
                    .padding(.trailing)
                    
                    Button(action: {
                        showingSortSheet = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Active filters display
                if viewModel.selectedGenre != nil || viewModel.selectedStatus != nil || viewModel.selectedFormat != nil {
                    FilterBadgesView(viewModel: viewModel)
                        .padding(.horizontal)
                }
                
                // Empty state view
                if viewModel.filteredBooks.isEmpty {
                    EmptyLibraryView(isFiltered: viewModel.books.count > 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Book collection list
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(viewModel.filteredBooks) { book in
                                NavigationLink(destination: BookDetailView(viewModel: BookDetailViewModel(bookId: book.id))) {
                                    BookCardView(book: book)
                                        .frame(height: 240)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddBookSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBookSheet) {
                NavigationView {
                    let formViewModel = BookFormViewModel()
                    BookFormView(viewModel: formViewModel)
                        .navigationTitle("Add New Book")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Cancel") {
                                    showingAddBookSheet = false
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Save") {
                                    if formViewModel.saveBook() {
                                        viewModel.loadBooks() // Refresh the book list
                                        showingAddBookSheet = false
                                    }
                                }
                            }
                        }
                }
                .onDisappear {
                    // Make sure to refresh books when sheet is dismissed
                    viewModel.loadBooks()
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                GenreFilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSortSheet) {
                SortBooksView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadBooks()
            }
        }
    }
}

// MARK: - FilterBadgesView

struct FilterBadgesView: View {
    @ObservedObject var viewModel: BookLibraryViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: {
                    viewModel.clearFilters()
                }) {
                    Text("Clear All")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.gray)
                        .cornerRadius(15)
                }
                
                if let genre = viewModel.selectedGenre {
                    FilterBadge(text: genre.rawValue, iconName: genre.iconName) {
                        viewModel.setGenreFilter(nil)
                    }
                }
                
                if let status = viewModel.selectedStatus {
                    FilterBadge(text: status.rawValue, iconName: status.iconName) {
                        viewModel.setStatusFilter(nil)
                    }
                }
                
                if let format = viewModel.selectedFormat {
                    FilterBadge(text: format.rawValue, iconName: format.iconName) {
                        viewModel.setFormatFilter(nil)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct FilterBadge: View {
    let text: String
    let iconName: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.caption)
            Text(text)
                .font(.caption)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .foregroundColor(.white)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.blue)
        .cornerRadius(15)
    }
}

// MARK: - Preview

struct BookLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        BookLibraryView(viewModel: BookLibraryViewModel())
    }
}
