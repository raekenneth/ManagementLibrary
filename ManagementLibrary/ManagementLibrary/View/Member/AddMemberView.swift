import SwiftUI

struct AddMemberView: View {
    @ObservedObject var memberViewModel: MemberViewModel
    @Binding var isPresented: Bool
    @State private var memberName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Details")) {
                    TextField("Member Name", text: $memberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMember()
                        isPresented = false // Close the sheet
                    }
                    .disabled(memberName.isEmpty)
                }
            }
        }
    }

    private func saveMember() {
        memberViewModel.addMember(name: memberName)
        memberName = "" // Reset input field
    }
}
