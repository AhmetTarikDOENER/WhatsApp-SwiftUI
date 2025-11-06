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
                Text("Participants: 12/12")
                    .bold()
            }
            .listRowBackground(Color.clear)
        }
    }
    
    //  MARK: - Private
    private func groupChatSetupHeaderView() -> some View {
        HStack {
            Circle()
                .frame(width: 60, height: 60)
            
            TextField(
                "",
                text: $channelName,
                prompt: Text("Group Name (optional)"),
                axis: .vertical
            )
        }
    }
}

#Preview {
    NewGroupSetupView(viewModel: .init())
}
