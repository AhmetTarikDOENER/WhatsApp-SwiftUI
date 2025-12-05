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
    private var animation: Animation {
        Animation.spring(
            response: 0.55,
            dampingFraction: 0.6,
            blendDuration: 0.05
        ).speed(3.5)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(emojiStates.enumerated()), id: \.offset) { index, item in
                reactionButton(item, at: index)
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
    
    private func reactionButton(_ reaction: EmojiReaction, at index: Int) -> some View {
        Button {
            
        } label: {
            buttonLabel(reaction, at: index)
                .scaleEffect(emojiStates[index].isAnimating ? 1 : 0.01)
                .opacity(reaction.opacity)
                .onAppear {
                    withAnimation(animation.delay(0.05 * Double(index))) {
                        emojiStates[index].isAnimating = true
                    }
                }
        }
    }
    
    @ViewBuilder
    private func buttonLabel(_ reaction: EmojiReaction, at index: Int) -> some View {
        if reaction.reaction == .more {
            Image(systemName: "plus")
                .bold()
                .padding(4)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .foregroundStyle(.gray)
        } else {
            Text(reaction.reaction.emoji)
        }
    }
}

#Preview {
    ZStack {
        Rectangle().fill(.thinMaterial)
        ReactionPickerView(message: .receivedPlaceholder)
    }
}
