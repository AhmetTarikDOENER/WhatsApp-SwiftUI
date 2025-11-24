import SwiftUI

struct BubbleTextView: View {
    
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if message.showGroupChatPartnerProfileImage {
                CircularProfileImageView(message.sender?.profileImageUrl, size: .mini)
            }
            
            if message.direction == .outgoing {
                timestampTextView()
            }
            
            Text(message.text)
                .padding(10)
                .background(message.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .applyTail(message.direction)
            
            if message.direction == .received {
                timestampTextView()
            }
        }
        .shadow(
            color: Color(.systemGray3).opacity(0.1),
            radius: 5,
            x: 0,
            y: 20
        )
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.leadingPadding)
        .padding(.trailing, message.trailingPadding)
    }
    
    //  MARK: - Private
    private func timestampTextView() -> some View {
        Text(message.timestamp.timeRepresentation)
            .font(.system(size: 13))
            .foregroundStyle(.gray)
    }
}

#Preview {
    ScrollView {
        BubbleTextView(message: .sentPlaceholder)
        BubbleTextView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(.green.opacity(0.1))
}
