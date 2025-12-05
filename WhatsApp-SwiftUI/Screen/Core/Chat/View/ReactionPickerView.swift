import SwiftUI

//  MARK: - EmojiReaction
struct EmojiReaction {
    let reaction: Reaction
    var isAnimating = false
    var opacity: CGFloat = 1
}

struct ReactionPickerView: View {
    
    @State private var emojiStates: [EmojiReaction] = [
        EmojiReaction(reaction: .like),
        EmojiReaction(reaction: .laugh),
        EmojiReaction(reaction: .heart),
        EmojiReaction(reaction: .sad),
        EmojiReaction(reaction: .shocked),
        EmojiReaction(reaction: .pray),
        EmojiReaction(reaction: .more)
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(emojiStates.enumerated()), id: \.offset) { index, item in
                Text(item.reaction.emoji)
                    .font(.system(size: 30))
            }
        }
    }
}

#Preview {
    ReactionPickerView()
}
