import Foundation

private func validateNonEmptyString(_ value: String, fieldName: String) -> Bool {
    if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        print("\(fieldName) cannot be empty.")
        return false
    }
    return true
}

class MemberViewModel: ObservableObject {
    @Published var members: [Member] = []

    init() {
        fetchMembers()
    }

    func fetchMembers() {
        members = DatabaseManager.shared.fetchMembers()
    }

    func addMember(name: String) {
        DatabaseManager.shared.addMember(name: name)
        fetchMembers()
    }

    func updateMember(memberID: Int32, name: String) {
        DatabaseManager.shared.updateMember(memberID: memberID, name: name)
        fetchMembers()
    }

    func deleteMember(memberID: Int32) {
        DatabaseManager.shared.deleteMember(memberID: memberID)
        fetchMembers()
    }
}
