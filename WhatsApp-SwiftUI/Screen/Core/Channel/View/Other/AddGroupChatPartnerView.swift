import SwiftUI

struct AddGroupChatPartnerView: View {
    
    //  MARK: - Property
    @State private var searchText = ""
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    
    var body: some View {
        List {
            if viewModel.showSelectedUsers {
                Text("Users selected")
            }
            
            Section {
                ForEach([UserItem.placeholder]) { user in
                    Button {
                        viewModel.handleUserSelection(user)
                    } label: {
                        chatPartnerRowView(user: .placeholder)
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
    }
    
    //  MARK: - Private
    private func chatPartnerRowView(user: UserItem) -> some View {
        ChatPartnerRowView(user: .placeholder) {
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

#Preview {
    NavigationStack {
        AddGroupChatPartnerView(viewModel: .init())
    }
}
