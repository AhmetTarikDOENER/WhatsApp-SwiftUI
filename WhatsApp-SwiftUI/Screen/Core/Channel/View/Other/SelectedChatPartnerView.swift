import SwiftUI

struct SelectedChatPartnerView: View {
    
    //  MARK: - Property
    let users: [UserItem]
    let onTapHandler: (_ user: UserItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { user in
                    chatPartnerView(user)
                }
            }
        }
    }
    
    //  MARK: - Private
    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack {
            CircularProfileImageView(user.profileImageURL, size: .medium)
                .overlay(alignment: .topTrailing) {
                    cancelButton(user)
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton(_ user: UserItem) -> some View {
        Button {
            onTapHandler(user)
        } label: {
            Image(systemName: "xmark")
                .imageScale(.small)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
                .background(Color(.systemGray3))
                .clipShape(Circle())
        }
    }
}

#Preview {
    SelectedChatPartnerView(users: UserItem.placeholders) { user in
        
    }
}
