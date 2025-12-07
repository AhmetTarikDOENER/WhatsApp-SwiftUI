import SwiftUI

struct MessageReactionView: View {
    
    let emojis = ["🥰","😜","🥳","😎"]
    let message: Message
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(emojis, id: \.self) { emoji in
                Text(emoji)
                    .fontWeight(.semibold)
            }
            
            Text("4")
                .fontWeight(.semibold)
        }
        .font(.footnote)
        .padding(4)
        .padding(.horizontal, 2)
        .background(Capsule().fill(.thinMaterial))
        .overlay (
            Capsule()
                .stroke(message.backgroundColor, lineWidth: 2)
        )
        .shadow(color: message.backgroundColor.opacity(0.3), radius: 4, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        MessageReactionView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.2))
}
