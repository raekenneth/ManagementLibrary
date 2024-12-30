import Foundation

struct Borrowing: Identifiable {
    var id: Int32
    var memberID: Int32
    var bookID: Int32
    var borrowDate: String
    var returnDate: String
    var isReturned: Bool 
}
