
import Foundation

private func validateNonEmptyString(_ value: String, fieldName: String) -> Bool {
    if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        print("\(fieldName) cannot be empty.")
        return false
    }
    return true
}

class BorrowingViewModel: ObservableObject {
    @Published var borrowings: [Borrowing] = []
    @Published var members: [Member] = []
    @Published var books: [Book] = []

    func fetchBorrowings() {
        borrowings = DatabaseManager.shared.fetchAllBorrowings()
    }

    func fetchMembers() {
        members = DatabaseManager.shared.fetchMembers()
    }

    func fetchBooks() {
        books = DatabaseManager.shared.fetchBooks()
    }

  
    
    func addBorrowing(memberID: Int32, bookID: Int32, borrowDate: String, returnDate: String) {
        DatabaseManager.shared.addBorrowing(memberID: memberID, bookID: bookID, borrowDate: borrowDate, returnDate: returnDate)
        fetchBorrowings()
    }
    
    func deleteBorrowing(at offsets: IndexSet) {
          for index in offsets {
              let borrowingID = borrowings[index].id
              DatabaseManager.shared.deleteBorrowing(borrowingID: borrowingID)
          }
          fetchBorrowings()
      }
//    
//    func returnBook(borrowingID: Int32) {
//        guard let borrowing = borrowings.first(where: { $0.id == borrowingID }) else {
//            print("Borrowing not found.")
//            return
//        }
//
//        let borrowDate = parseDate(borrowing.borrowDate)
//        let deadline = Calendar.current.date(byAdding: .day, value: 7, to: borrowDate)!
//
//        if Date() > deadline {
//            print("The book is being returned late.")
//        } else {
//            print("The book is returned on time.")
//        }
//
//        // Hapus peminjaman dari database
//        DatabaseManager.shared.deleteBorrowing(borrowingID: borrowingID)
//        fetchBorrowings()
//    }
    func returnBook(borrowingID: Int32) {
        if let index = borrowings.firstIndex(where: { $0.id == borrowingID }) {
            borrowings[index].isReturned = true
            // Simpan perubahan ke database jika diperlukan
        }
    }
    func parseDate(_ dateString: String) -> Date {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"
           return formatter.date(from: dateString) ?? Date.distantPast
       }
    
    var activeBorrowings: [Borrowing] {
        borrowings.filter { !$0.isReturned }
    }

    var returnedBorrowings: [Borrowing] {
        borrowings.filter { $0.isReturned }
    }

}
