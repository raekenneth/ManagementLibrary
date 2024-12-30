import SwiftUI

struct EditBookView: View {
    @ObservedObject var bookViewModel: BookViewModel
    @State private var book: Book
    @State private var title: String
    @State private var author: String
    @State private var showConfirmationDialog = false

    init(bookViewModel: BookViewModel, book: Book) {
        self.bookViewModel = bookViewModel
        self._book = State(initialValue: book)
        self._title = State(initialValue: book.title)
        self._author = State(initialValue: book.author)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Book Details").font(.headline)) {
                TextField("Book Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                TextField("Author Name", text: $author)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
            }

            Section {
                Button(action: {
                    showConfirmationDialog = true
                }) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("Edit Book")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize fields if needed
            title = book.title
            author = book.author
        }
        .alert(isPresented: $showConfirmationDialog) {
            Alert(
                title: Text("Save Changes?"),
                message: Text("Are you sure you want to update this book's details?"),
                primaryButton: .default(Text("Save"), action: saveChanges),
                secondaryButton: .cancel()
            )
        }
    }

    private func saveChanges() {
        guard !title.isEmpty, !author.isEmpty else {
            return // Optional: Add error handling for empty fields
        }
        bookViewModel.updateBook(bookID: book.id, title: title, author: author)
    }
}
