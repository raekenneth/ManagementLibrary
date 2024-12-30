import SwiftUI

struct BookListView: View {
    @StateObject private var bookViewModel = BookViewModel()
    @State private var isAddingBook = false
    @State private var showDeleteConfirmation = false
    @State private var bookToDelete: Book?

    var body: some View {
        NavigationView {
            VStack {
                // List with swipe-to-delete and tap-to-edit
                List {
                    ForEach(bookViewModel.books, id: \.id) { book in
                        if isValidBook(book) { // Validasi buku sebelum ditampilkan
                            NavigationLink(destination: AddBookView(bookViewModel: bookViewModel, book: book)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(book.title.isEmpty ? "Untitled" : book.title)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(book.author.isEmpty ? "Unknown Author" : "Author: \(book.author)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    bookToDelete = book
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        } else {
                            Text("Invalid book data")
                                .foregroundColor(.red)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle()) // Modern iOS style
                .navigationTitle("Books")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isAddingBook.toggle() }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $isAddingBook) {
                    AddBookView(bookViewModel: bookViewModel)
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure you want to delete this book?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let book = bookToDelete {
                                deleteBook(book: book)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    private func isValidBook(_ book: Book) -> Bool {
        // Validasi apakah buku memiliki title dan author
        return !book.title.isEmpty && !book.author.isEmpty
    }

    private func deleteBook(book: Book) {
        bookViewModel.deleteBook(bookID: book.id)
    }
}
