//
//  BookFormView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct BookFormView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: BookFormViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDiscardAlert = false
    @State private var showingPublicationDatePicker = false
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Error section
            if !viewModel.formErrors.isEmpty {
                Section(header: Text("Errors")) {
                    ForEach(viewModel.formErrors, id: \.self) { error in
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Basic information
            Section(header: Text("Basic Information")) {
                TextField("Title", text: $viewModel.title)
                TextField("Author", text: $viewModel.author)
            }
            
            // Book details
            Section(header: Text("Book Details")) {
                Picker("Genre", selection: $viewModel.genre) {
                    ForEach(BookGenre.allCases) { genre in
                        Label(genre.rawValue, systemImage: genre.iconName)
                            .tag(genre)
                    }
                }
                
                Picker("Format", selection: $viewModel.format) {
                    ForEach(BookFormat.allCases) { format in
                        Label(format.rawValue, systemImage: format.iconName)
                            .tag(format)
                    }
                }
                
                Picker("Reading Status", selection: $viewModel.status) {
                    ForEach(ReadingStatus.allCases) { status in
                        Label(status.rawValue, systemImage: status.iconName)
                            .tag(status)
                    }
                }
                
                // Publication date picker
                HStack {
                    Text("Publication Date")
                    Spacer()
                    Button(action: {
                        showingPublicationDatePicker.toggle()
                    }) {
                        Text(viewModel.publicationDate == nil ? "Not Set" : 
                            viewModel.publicationDate!.formatted(.dateTime.day().month().year()))
                            .foregroundColor(viewModel.publicationDate == nil ? .secondary : .primary)
                    }
                }
                
                if showingPublicationDatePicker {
                    DatePicker("", selection: Binding(
                        get: { viewModel.publicationDate ?? Date() },
                        set: { viewModel.publicationDate = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    
                    Button("Clear Date") {
                        viewModel.publicationDate = nil
                    }
                    .foregroundColor(.red)
                }
            }
            
            // Rating
            Section(header: Text("Rating")) {
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: (viewModel.rating ?? 0) >= star ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title2)
                            .onTapGesture {
                                viewModel.setRating(star)
                            }
                    }
                    
                    if viewModel.rating != nil {
                        Button(action: {
                            viewModel.clearRating()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        .padding(.leading)
                    }
                }
            }
            
            // Notes
            Section(header: Text("Notes")) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                    
                    if viewModel.notes.isEmpty {
                        Text("Add your thoughts about this book...")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
            }
            
            // Save button
            Section {
                Button(action: {
                    let success = viewModel.saveBook()
                    if success {
                        // Small delay to allow the repository to update
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text(viewModel.saveButtonText)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(viewModel.isSaving || viewModel.title.isEmpty || viewModel.author.isEmpty)
            }
        }
        .navigationTitle(viewModel.formTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if viewModel.hasInput {
                        showingDiscardAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert(isPresented: $showingDiscardAlert) {
            Alert(
                title: Text("Discard Changes?"),
                message: Text("You have unsaved changes. Are you sure you want to discard them?"),
                primaryButton: .destructive(Text("Discard")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .disabled(viewModel.isSaving)
    }
}

// MARK: - Preview

struct BookFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookFormView(viewModel: BookFormViewModel())
        }
    }
}
