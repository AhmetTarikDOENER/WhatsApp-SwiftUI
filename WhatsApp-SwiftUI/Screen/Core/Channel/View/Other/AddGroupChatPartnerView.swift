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
            
            Image(systemName: "circle")
                .foregroundStyle(Color(.systemGray4))
                .imageScale(.large)
        }
    }
}

#Preview {
    NavigationStack {
        AddGroupChatPartnerView(viewModel: .init())
    }
}
