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
        }
    }
    
    private func nameAndTimestampView() -> some View {
        HStack {
            Text(channel.title)
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text("17:50")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text(channel.lastMessage)
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
