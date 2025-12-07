import SwiftUI

struct MessageReactionView: View {
    
    //  MARK: - Properties
    let message: Message
    
    private var emojis: [String] { message.reactions.map { $0.key } }
    private var emojiCount: Int {
        let count = message.reactions.map { $0.value }
        return count.reduce(0, +)
    }
    
    var body: some View {
        if message.hasReactions {
            HStack(spacing: 2) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .fontWeight(.semibold)
                }
                
                if emojiCount > 2 {
                    Text("\(emojiCount)")
                        .fontWeight(.semibold)
                }
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
            .onAppear {
                print("\(message.reactions.map({ $0.key }))")
            }
        }
    }
}

#Preview {
    ZStack {
        MessageReactionView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.2))
}
