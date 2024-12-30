
import Foundation

private func validateNonEmptyString(_ value: String, fieldName: String) -> Bool {
    if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        print("\(fieldName) cannot be empty.")
        return false
    }
    return true
}
class BookViewModel: ObservableObject {
    @Published var books: [Book] = []

    init() {
        fetchBooks()
    }

    func fetchBooks() {
        // Mengambil data buku dari DatabaseManager
        books = DatabaseManager.shared.fetchBooks()
        print("Fetched books: \(books)") // Debug output untuk melihat apakah data sudah diambil
    }

    func addBook(title: String, author: String) -> Int32 {
        // Menambahkan buku baru ke database
        let bookID = DatabaseManager.shared.addBook(title: title, author: author)
        fetchBooks() // Refresh daftar buku
        return bookID
    }

    func deleteBook(bookID: Int32) {
        // Menghapus buku dari database
        DatabaseManager.shared.deleteBook(bookID: bookID)
        fetchBooks() // Refresh daftar buku
    }

    func updateBook(bookID: Int32, title: String, author: String) {
        // Memperbarui buku di database
        DatabaseManager.shared.updateBook(bookID: bookID, title: title, author: author)
        fetchBooks() // Refresh daftar buku
    }

    func saveOrUpdateBook(book: Book?, title: String, author: String) {
        // Menyimpan atau memperbarui buku
        guard !title.isEmpty && !author.isEmpty else {
            print("Title or Author is empty, cannot save or update.") // Debug untuk mengecek
            return
        }

        if let book = book {
            // Update buku
            updateBook(bookID: book.id, title: title, author: author)
        } else {
            // Menambah buku baru
            addBook(title: title, author: author)
        }
    }
}
