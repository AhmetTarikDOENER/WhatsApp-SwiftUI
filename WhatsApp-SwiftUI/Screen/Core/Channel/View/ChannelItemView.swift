import SwiftUI

struct ChannelItemView: View {
    
    let channel: Channel
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CircularProfileImageView(channel, size: .large)
            
            VStack(alignment: .leading, spacing: 4) {
                nameAndTimestampView()
                lastMessagePreview()
            }
            .overlay(alignment: .bottomTrailing) {
                if channel.unreadMessageCount > 0 {
                    unreadMessageCountView(count: channel.unreadMessageCount)
                }
            }
        }
    }
    
    private func nameAndTimestampView() -> some View {
        HStack {
            Text(channel.title)
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text(channel.lastMessageTimestamp.dayOrTimeRepresentation)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        HStack(spacing: 4) {
            if channel.lastMessageType != .text {
                Image(systemName: channel.lastMessageType.iconName)
                    .imageScale(.small)
                    .foregroundStyle(.gray)
            }
            
            Text(channel.messagePreview)
                .font(.system(size: 16))
                .lineLimit(2)
                .foregroundStyle(.gray)
        }
    }
    
    private func unreadMessageCountView(count: Int) -> some View {
        Text(count.description)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(.badge)
            .bold()
            .font(.caption)
            .clipShape(Capsule())
        
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
