import SwiftUI

struct SelectedChatPartnerView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(UserItem.placeholders) { user in
                    chatPartnerView(user)
                }
            }
        }
    }
    
    //  MARK: - Private
    private func chatPartnerView(_ user: UserItem) -> some View {
        VStack {
            Circle()
                .fill(Color(.systemGray4))
                .frame(width: 60, height: 60)
                .overlay(alignment: .topTrailing) {
                    cancelButton()
                }
            
            Text(user.username)
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            
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
    SelectedChatPartnerView()
}
