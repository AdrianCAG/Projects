//
//  GenreFilterView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct GenreFilterView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: BookLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selection
                Picker("Filter Type", selection: $selectedTab) {
                    Text("Genre").tag(0)
                    Text("Status").tag(1)
                    Text("Format").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Filter content based on selected tab
                TabView(selection: $selectedTab) {
                    // Genre filters
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(BookGenre.allCases) { genre in
                                FilterOptionRow(
                                    title: genre.rawValue,
                                    iconName: genre.iconName,
                                    count: viewModel.genreCounts[genre] ?? 0,
                                    isSelected: viewModel.selectedGenre == genre
                                ) {
                                    viewModel.setGenreFilter(viewModel.selectedGenre == genre ? nil : genre)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .tag(0)
                    
                    // Status filters
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(ReadingStatus.allCases) { status in
                                FilterOptionRow(
                                    title: status.rawValue,
                                    iconName: status.iconName,
                                    count: viewModel.statusCounts[status] ?? 0,
                                    isSelected: viewModel.selectedStatus == status
                                ) {
                                    viewModel.setStatusFilter(viewModel.selectedStatus == status ? nil : status)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .tag(1)
                    
                    // Format filters
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(BookFormat.allCases) { format in
                                FilterOptionRow(
                                    title: format.rawValue,
                                    iconName: format.iconName,
                                    count: viewModel.books.filter { $0.format == format }.count,
                                    isSelected: viewModel.selectedFormat == format
                                ) {
                                    viewModel.setFormatFilter(viewModel.selectedFormat == format ? nil : format)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Filter Books")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(viewModel.selectedGenre == nil && 
                              viewModel.selectedStatus == nil && 
                              viewModel.selectedFormat == nil)
                }
            }
        }
    }
}

// MARK: - FilterOptionRow

struct FilterOptionRow: View {
    let title: String
    let iconName: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 24)
                
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Spacer()
                
                Text("\(count)")
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .font(.subheadline)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct GenreFilterView_Previews: PreviewProvider {
    static var previews: some View {
        GenreFilterView(viewModel: {
            let vm = BookLibraryViewModel()
            // Initialize with some sample data
            return vm
        }())
    }
}
