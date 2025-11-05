import SwiftUI

struct AddGroupChatPartnerView: View {
    
    //  MARK: - Property
    @State private var searchText = ""
    
    var body: some View {
        List {
            Section {
                ForEach(0 ..< 11) { _ in
                    Button {
                        print("Selected")
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
        AddGroupChatPartnerView()
    }
}
