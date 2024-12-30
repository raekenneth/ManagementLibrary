
import SwiftUI

struct AddBorrowingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BorrowingViewModel
    @State private var selectedMemberID: Int32? = nil
    @State private var selectedBookID: Int32? = nil
    @State private var borrowDate: Date = Date()
    @State private var returnDate: Date = Date()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                // Member Picker
                Picker("Select Member", selection: $selectedMemberID) {
                    Text("Choose a Member").tag(Int32?.none)
                    ForEach(viewModel.members, id: \.id) { member in
                        Text(member.name).tag(Optional(member.id))
                    }
                }

                // Book Picker
                Picker("Select Book", selection: $selectedBookID) {
                    Text("Choose a Book").tag(Int32?.none)
                    ForEach(viewModel.books, id: \.id) { book in
                        Text(book.title).tag(Optional(book.id))
                    }
                }

                // Borrow Date Picker
                DatePicker("Borrow Date", selection: $borrowDate, displayedComponents: .date)

                // Return Date Picker
                DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
            }
            .navigationTitle("Add Borrower")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateInput() {
                            if let bookID = selectedBookID {
                                // Cek konflik tanggal peminjaman
                                if hasDateConflict(bookID: bookID, borrowDate: borrowDate, returnDate: returnDate) {
                                    errorMessage = "The selected book is already borrowed during the selected period."
                                    showError = true
                                } else {
                                    // Tambahkan peminjaman jika tidak ada konflik
                                    viewModel.addBorrowing(
                                        memberID: selectedMemberID!,
                                        bookID: bookID,
                                        borrowDate: formatDate(borrowDate),
                                        returnDate: formatDate(returnDate)
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                errorMessage = "Please select a book."
                                showError = true
                            }
                        } else {
                            errorMessage = "Please check your input data."
                            showError = true
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.fetchMembers()
                viewModel.fetchBooks()
            }
        }
    }

    // Validasi apakah ada konflik tanggal
    func hasDateConflict(bookID: Int32, borrowDate: Date, returnDate: Date) -> Bool {
        let normalizedBorrowDate = normalizeDate(borrowDate)
        let normalizedReturnDate = normalizeDate(returnDate)

        for borrowing in viewModel.borrowings where borrowing.bookID == bookID {
            let existingBorrowDate = normalizeDate(parseDate(borrowing.borrowDate))
            let existingReturnDate = normalizeDate(parseDate(borrowing.returnDate) ?? Date.distantFuture)

            print("Checking conflict for bookID \(bookID):")
            print("New borrow range: \(normalizedBorrowDate) to \(normalizedReturnDate)")
            print("Existing range: \(existingBorrowDate) to \(existingReturnDate)")

            // Cek overlap rentang tanggal (tanpa waktu)
            if normalizedBorrowDate <= existingReturnDate && normalizedReturnDate >= existingBorrowDate {
                return true
            }
        }
        return false
    }

    func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }


    func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date.distantPast
    }

    func validateInput() -> Bool {
        return selectedMemberID != nil && selectedBookID != nil
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
