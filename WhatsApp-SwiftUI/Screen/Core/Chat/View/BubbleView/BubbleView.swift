import SwiftUI

struct BubbleView: View {
    
    let message: Message
    let channel: Channel
    let isNewDay: Bool
    let showSenderName: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimestampTextView()
                    .padding()
            }
            
            if showSenderName {
                senderNameTextView()
            }
            
            makeDynamicBubbleView()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func makeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(message: message)
        case .photo, .video:
            BubbleImageView(message: message)
        case .audio:
            BubbleAudioView(message: message)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                newDayTimestampTextView()
                
                ChannelCreationTextView()
                    .padding()
                
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                }
            default:
                Text("Unknown")
            }
        }
    }
    
    private func newDayTimestampTextView() -> some View {
        Text(message.timestamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background(.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
    
    private func senderNameTextView() -> some View {
        Text(message.sender?.username ?? "Unknown")
            .lineLimit(1)
            .foregroundStyle(.gray)
            .font(.footnote)
            .padding(.bottom, 2)
            .padding(.horizontal)
            .padding(.leading, 16)
    }
}

#Preview {
    BubbleView(
        message: .sentPlaceholder,
        channel: .placeholder,
        isNewDay: false,
        showSenderName: false
    )
}
