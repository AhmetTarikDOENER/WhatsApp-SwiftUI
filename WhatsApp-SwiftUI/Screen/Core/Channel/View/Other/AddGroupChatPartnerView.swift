import SwiftUI

struct AddGroupChatPartnerView: View {
    
    @State private var searchText = ""
    
    var body: some View {
        List {
            Text("TEXT")
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search name or number"
        )
    }
}

#Preview {
    NavigationStack {
        AddGroupChatPartnerView()
    }
}
