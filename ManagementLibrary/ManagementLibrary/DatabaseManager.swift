import SQLite3
import Foundation


class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    init() {
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("ManagementLibrary.sqlite")
            print("Database path: \(fileURL.path)")

            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("Error opening database: \(String(cString: sqlite3_errmsg(db)))")
            } else {
                print("Database opened successfully")
            }
        } catch {
            print("Error locating database file: \(error.localizedDescription)")
        }
    }

    private func createTables() {
        let createBookTable = """
        CREATE TABLE IF NOT EXISTS Books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT
        );
        """

        let createMemberTable = """
        CREATE TABLE IF NOT EXISTS Members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        );
        """

        
        let createBorrowingsTable = """
        CREATE TABLE IF NOT EXISTS Borrowings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            memberID INTEGER,
            bookID INTEGER,
            borrowDate DATE,
            returnDate DATE,
            FOREIGN KEY (memberID) REFERENCES Members(id),
            FOREIGN KEY (bookID) REFERENCES Books(id)
        );
        """

  
        executeSQL(createBookTable)
        executeSQL(createMemberTable)
        executeSQL(createBorrowingsTable)
    }

    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        } else {
            print("Error executing SQL: \(sql)")
        }
        sqlite3_finalize(statement)
    }

    deinit {
        sqlite3_close(db)
    }

    // MARK: - CRUD Operations for Borrowings
    func addBorrowing(memberID: Int32, bookID: Int32, borrowDate: String, returnDate: String) {
        let sql = "INSERT INTO Borrowings (memberID, bookID, borrowDate, returnDate) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, memberID)
            sqlite3_bind_int(statement, 2, bookID)
            sqlite3_bind_text(statement, 3, (borrowDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (returnDate as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Borrowing added successfully!")
            } else {
                print("Error adding borrowing.")
            }
        }
        sqlite3_finalize(statement)
    }



    
    func prepareStatement(_ query: String) -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            return statement
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
    }



    
    func deleteBorrowing(borrowingID: Int32) {
        let query = "DELETE FROM Borrowings WHERE id = ?"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, borrowingID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully deleted borrowing")
            } else {
                print("Failed to delete borrowing")
            }
        }
        sqlite3_finalize(statement)
    }

    
    func fetchAllBorrowings() -> [Borrowing] {
        var borrowings: [Borrowing] = []
        let query = "SELECT * FROM Borrowings"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let memberID = sqlite3_column_int(statement, 1)
                let bookID = sqlite3_column_int(statement, 2)
                let borrowDate = String(cString: sqlite3_column_text(statement, 3))
                let returnDate = String(cString: sqlite3_column_text(statement, 4))
                
                let borrowing = Borrowing(
                    id: id,
                    memberID: memberID,
                    bookID: bookID,
                    borrowDate: borrowDate,
                    returnDate: returnDate,
                    isReturned: false
                )
                borrowings.append(borrowing)
            }
        }
        sqlite3_finalize(statement)
        return borrowings
    }

    func fetchBorrowingsByMember(memberID: Int32) -> [Borrowing] {
        let query = """
        SELECT Borrowings.id, Borrowings.bookID,
               Borrowings.borrowDate, Borrowings.returnDate, Borrowings.isReturned
        FROM Borrowings
        WHERE Borrowings.memberID = ? AND Borrowings.isReturned = 0;
        """
        var borrowings: [Borrowing] = []
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, memberID)
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let bookID = sqlite3_column_int(statement, 1)
                let borrowDate = String(cString: sqlite3_column_text(statement, 2))
                let returnDate = String(cString: sqlite3_column_text(statement, 3))
                let isReturned = sqlite3_column_int(statement, 4) == 1

                let borrowing = Borrowing(
                    id: id,
                    memberID: memberID,
                    bookID: bookID,
                    borrowDate: borrowDate,
                    returnDate: returnDate,
                    isReturned: false
                )
                borrowings.append(borrowing)
            }
        }
        sqlite3_finalize(statement)
        return borrowings
    }
    
    // MARK: - CRUD for Books
    func addBook(title: String, author: String) -> Int32 {
        let sql = "INSERT INTO Books (title, author) VALUES (?, ?);"
        var statement: OpaquePointer?
        var newBookID: Int32 = -1

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (author as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                // Mendapatkan ID terakhir yang dimasukkan
                newBookID = Int32(sqlite3_last_insert_rowid(db))
                print("Book added successfully with ID: \(newBookID)")
            } else {
                print("Error adding book.")
            }
        } else {
            print("Error preparing statement for adding book.")
        }
        sqlite3_finalize(statement)
        return newBookID
    }


    func fetchBooks() -> [Book] {
        let sql = "SELECT id, title, author FROM Books;"
        var statement: OpaquePointer?
        var books: [Book] = []

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let author = String(cString: sqlite3_column_text(statement, 2))
                books.append(Book(id: id, title: title, author: author))
            }
        }
        sqlite3_finalize(statement)
        return books
    }

    func updateBook(bookID: Int32, title: String, author: String) {
        let sql = "UPDATE Books SET title = ?, author = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (author as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, bookID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Book updated successfully!")
            } else {
                print("Error updating book.")
            }
        }
        sqlite3_finalize(statement)
    }

    func deleteBook(bookID: Int32) {
        let sql = "DELETE FROM Books WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, bookID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Book deleted successfully!")
            } else {
                print("Error deleting book.")
            }
        }
        sqlite3_finalize(statement)
    }

    // MARK: - CRUD for Members
    func addMember(name: String) {
        let sql = "INSERT INTO Members (name) VALUES (?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Member added successfully!")
            } else {
                print("Error adding member.")
            }
        }
        sqlite3_finalize(statement)
    }

    func fetchMembers() -> [Member] {
        let sql = "SELECT id, name FROM Members;"
        var statement: OpaquePointer?
        var members: [Member] = []

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                members.append(Member(id: id, name: name))
            }
        }
        sqlite3_finalize(statement)
        return members
    }

    func updateMember(memberID: Int32, name: String) {
        let sql = "UPDATE Members SET name = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, memberID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Member updated successfully!")
            } else {
                print("Error updating member.")
            }
        }
        sqlite3_finalize(statement)
    }

    func deleteMember(memberID: Int32) {
        let sql = "DELETE FROM Members WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, memberID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Member deleted successfully!")
            } else {
                print("Error deleting member.")
            }
        }
        sqlite3_finalize(statement)
    }
}
