import SwiftUI

//  MARK: - EmojiReaction
struct EmojiReaction {
    let reaction: Reaction
    var isAnimating = false
    var opacity: CGFloat = 1
}

struct ReactionPickerView: View {
    
    //  MARK: - Properties
    @State private var animateBackground = false
    @State private var emojiStates: [EmojiReaction] = [
        EmojiReaction(reaction: .like),
        EmojiReaction(reaction: .laugh),
        EmojiReaction(reaction: .heart),
        EmojiReaction(reaction: .sad),
        EmojiReaction(reaction: .shocked),
        EmojiReaction(reaction: .pray),
        EmojiReaction(reaction: .more)
    ]
    
    let message: Message
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(emojiStates.enumerated()), id: \.offset) { index, item in
                Text(item.reaction.emoji)
                    .font(.system(size: 30))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundView())
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                animateBackground = true
            }
        }
    }
    
    //  MARK: - Private
    private func backgroundView() -> some View {
        Capsule()
            .fill(.contextMenuTint)
            .mask {
                Capsule()
                    .fill(.contextMenuTint)
                    .scaleEffect(animateBackground ? 1 : 0, anchor: message.menuAnchor)
                    .opacity(animateBackground ? 1 : 0)
            }
    }
}

#Preview {
    ZStack {
        Rectangle().fill(.thinMaterial)
        ReactionPickerView(message: .receivedPlaceholder)
    }
}
