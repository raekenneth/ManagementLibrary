import SwiftUI

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bookViewModel: BookViewModel

    @State private var title: String = ""
    @State private var author: String = ""
    var book: Book? // Optional Book for editing

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Book Details")) {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                }
            }
            .navigationTitle(book == nil ? "Add Book" : "Edit Book")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(book == nil ? "Save" : "Update") {
                        saveOrUpdateBook()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty) // Disable button if fields are empty
                }
            }
        }
    }

    private func saveOrUpdateBook() {
        bookViewModel.saveOrUpdateBook(
            book: book,
            title: title,
            author: author
        )
    }
}
