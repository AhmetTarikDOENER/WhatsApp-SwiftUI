import SwiftUI

struct ChatPartnerRowView: View {
    
    let user: UserItem
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .foregroundStyle(.whatsAppBlack)
                    .bold()
                
                Text(user.bioUnwrapped)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder)
}
