import SwiftUI

struct ChannelItemView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 4) {
                nameAndTimestampView()
                lastMessagePreview()
            }
        }
    }
    
    private func nameAndTimestampView() -> some View {
        HStack {
            Text("Tim Cook")
                .lineLimit(1)
                .bold()
            
            Spacer()
            
            Text("17:50")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text("Welcome to WhatsApp")
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView()
}
