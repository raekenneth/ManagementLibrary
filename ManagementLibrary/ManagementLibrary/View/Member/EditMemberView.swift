
import SwiftUI

struct EditMemberView: View {
    var member: Member
    @ObservedObject var memberViewModel: MemberViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var memberName: String

    init(member: Member, memberViewModel: MemberViewModel) {
        self.member = member
        self.memberViewModel = memberViewModel
        _memberName = State(initialValue: member.name) // Isi awal dengan nama anggota
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Name")) {
                    TextField("Member Name", text: $memberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .navigationTitle("Edit Member")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMember()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(memberName.isEmpty)
                }
            }
        }
    }

    private func saveMember() {
        memberViewModel.updateMember(memberID: member.id, name: memberName)
    }
}

