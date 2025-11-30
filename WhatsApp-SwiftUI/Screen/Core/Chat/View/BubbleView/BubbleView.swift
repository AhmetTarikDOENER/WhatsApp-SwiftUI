import SwiftUI

struct BubbleView: View {
    
    let message: Message
    let channel: Channel
    let isNewDay: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimestampTextView()
            }
            
            makeDynamicBubbleView()
        }
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
                ChannelCreationTextView()
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
}

#Preview {
    BubbleView(message: .sentPlaceholder, channel: .placeholder, isNewDay: false)
}
