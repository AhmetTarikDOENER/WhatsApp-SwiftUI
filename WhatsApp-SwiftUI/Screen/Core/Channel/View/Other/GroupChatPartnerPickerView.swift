import SwiftUI

struct GroupChatPartnerPickerView: View {
    
    //  MARK: - Property
    @State private var searchText = ""
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    
    var body: some View {
        List {
            if viewModel.showSelectedUsers {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleUserSelection(user)
                }
            }
            
            Section {
                ForEach(UserItem.placeholders) { user in
                    Button {
                        viewModel.handleUserSelection(user)
                    } label: {
                        chatPartnerRowView(user: user)
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showSelectedUsers)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search name or number"
        )
        .toolbar {
            principleNavigationBarItem()
            trailingNavigationBarItem()
        }
    }
    
    //  MARK: - Private
    private func chatPartnerRowView(user: UserItem) -> some View {
        ChatPartnerRowView(user: user) {
            Spacer()
            
            let isSelected = viewModel.isUserSelected(user)
            let imageName = isSelected ? "checkmark.circle.fill" : "circle"
            let foregroundStyle = isSelected ? Color.blue : Color(.systemGray4)
            Image(systemName: imageName)
                .foregroundStyle(foregroundStyle)
                .imageScale(.large)
        }
    }
}

//  MARK: - GroupChatPartnerPickerView
private extension GroupChatPartnerPickerView {
    @ToolbarContentBuilder
    private func principleNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Participant")
                    .bold()
                
                let count = viewModel.selectedChatPartners.count
                Text("\(count)/\(ChannelConstants.maxGroupParticipantCount)")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Next") {
                viewModel.navigationStack.append(.setupGroupChat)
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupChatPartnerPickerView(viewModel: .init())
    }
}
