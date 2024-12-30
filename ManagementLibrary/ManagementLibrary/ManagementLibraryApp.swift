import SwiftUI
@main
struct ManagementLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                BookListView() // Langsung tanpa NavigationView
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Books")
                    }
                
                
                MemberListView() // Sama halnya untuk view lain
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Members")
                    }
                
                BorrowingListView()
                              .tabItem {
                                  Label("Borrowings", systemImage: "arrow.2.squarepath")
                              }
            }
        }
    }
}
