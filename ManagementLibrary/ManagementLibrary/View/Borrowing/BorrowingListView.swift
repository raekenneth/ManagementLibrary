import SwiftUI

struct BorrowingListView: View {
    @StateObject private var viewModel = BorrowingViewModel()
    @State private var showingAddView = false
    @State private var selectedTab = 0 // Tab untuk memisahkan Active dan History
    @State private var selectedMemberID: Int32? = nil

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Filter anggota
                HStack {
                    Spacer()
                    Picker("Select Member", selection: $selectedMemberID) {
                        Text("All Members").tag(Int32?.none)
                        ForEach(viewModel.members, id: \.id) { member in
                            Text(member.name).tag(member.id as Int32?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding([.leading, .trailing, .top])

                // Daftar pinjaman
                List {
                    ForEach(selectedTab == 0 ? filteredActiveBorrowings : filteredReturnedBorrowings, id: \.id) { borrowing in
                        VStack(alignment: .leading) {
                            if let memberName = viewModel.members.first(where: { $0.id == borrowing.memberID })?.name {
                                Text("Member: \(memberName)").font(.headline)
                            } else {
                                Text("Member: Unknown").font(.headline)
                            }

                            if let bookTitle = viewModel.books.first(where: { $0.id == borrowing.bookID })?.title {
                                Text("Book: \(bookTitle)")
                            } else {
                                Text("Book: Unknown")
                            }

                            Text("Borrow Date: \(borrowing.borrowDate)")
                            Text("Return Date: \(borrowing.returnDate)")

                            if selectedTab == 0 { // Tombol hanya untuk active borrowings
                                Button(action: {
                                    viewModel.returnBook(borrowingID: borrowing.id)
                                }) {
                                    Text("Return Book")
                                        .foregroundColor(.blue)
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteBorrowing)
                }
            }
            .navigationTitle("Borrowings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddView) {
                AddBorrowingView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchBorrowings()
                viewModel.fetchMembers()
                viewModel.fetchBooks()
            }
        }
    }

    // Filter daftar peminjaman aktif berdasarkan anggota yang dipilih
    private var filteredActiveBorrowings: [Borrowing] {
        if let memberID = selectedMemberID {
            return viewModel.activeBorrowings.filter { $0.memberID == memberID }
        } else {
            return viewModel.activeBorrowings
        }
    }

    // Filter daftar peminjaman yang sudah dikembalikan
    private var filteredReturnedBorrowings: [Borrowing] {
        if let memberID = selectedMemberID {
            return viewModel.returnedBorrowings.filter { $0.memberID == memberID }
        } else {
            return viewModel.returnedBorrowings
        }
    }
}
