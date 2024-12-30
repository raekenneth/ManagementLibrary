import SwiftUI

struct MemberListView: View {
    @ObservedObject var memberViewModel = MemberViewModel()
    @State private var isShowingAddMemberSheet = false
    @State private var selectedMember: Member? = nil // State untuk anggota yang akan diedit

    var body: some View {
        NavigationView {
            VStack {
                // List Members
                List {
                    ForEach(memberViewModel.members) { member in
                        HStack {
                            Text(member.name)
                            Spacer()
                            // Edit Member Button
                            Button(action: {
                                selectedMember = member // Set member yang akan diedit
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            // Delete Member Button
                            Button(action: {
                                memberViewModel.deleteMember(memberID: member.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .onAppear {
                    memberViewModel.fetchMembers()
                }
            }
            .navigationTitle("Members")
            .toolbar {
                // Add Member Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddMemberSheet.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Add Member Sheet
            .sheet(isPresented: $isShowingAddMemberSheet) {
                AddMemberView(memberViewModel: memberViewModel, isPresented: $isShowingAddMemberSheet)
            }
            // Edit Member Sheet
            .sheet(item: $selectedMember) { member in
                EditMemberView(member: member, memberViewModel: memberViewModel)
                    .onDisappear {
                        selectedMember = nil // Reset selected member setelah selesai edit
                    }
            }
        }
    }
}
