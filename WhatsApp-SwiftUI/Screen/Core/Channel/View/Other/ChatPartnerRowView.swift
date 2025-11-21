import SwiftUI

struct ChatPartnerRowView<Content: View>: View {
    
    private let user: UserItem
    private let trailingRowContent: Content
    
    init(
        user: UserItem,
        @ViewBuilder trailingRowContent: () -> Content = { EmptyView() }
    ) {
        self.user = user
        self.trailingRowContent = trailingRowContent()
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(user.profilImageUrl, size: .small)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .foregroundStyle(.whatsAppBlack)
                    .bold()
                
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            trailingRowContent
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder) {
        Image(systemName: "chevron.right")
    }
}
