import SwiftUI

struct NewGroupSetupView: View {
    
    //  MARK: - Property
    @State private var channelName = ""
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    
    var body: some View {
        List {
            Section {
                groupChatSetupHeaderView()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleUserSelection(user)
                }
            } header: {
                let count = viewModel.selectedChatPartners.count
                let maxParticipantCount = ChannelConstants.maxGroupParticipantCount
                Text("Participants: \(count) of \(maxParticipantCount)")
                    .bold()
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("New Group")
        .toolbar {
            trailingNavigationBarItem()
        }
    }
    
    //  MARK: - Private
    private func groupChatSetupHeaderView() -> some View {
        HStack {
            profileImageView()
            
            TextField(
                "",
                text: $channelName,
                prompt: Text("Group Name (optional)"),
                axis: .vertical
            )
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
    
    private func profileImageView() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
            }
        }
        .frame(width: 60, height: 60)
        .background(Color(.systemGray6))
        .clipShape(Circle())
    }
}

#Preview {
    NavigationStack {
        NewGroupSetupView(viewModel: .init())
    }
}
