import SwiftUI

private struct BubbleTailViewModifier: ViewModifier {
    
    var direction: MessageDirection
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: direction == .received ? .bottomLeading : .bottomTrailing) {
                BubbleTailView(direction: direction)
            }
    }
}

extension View {
    func applyTail(_ direction: MessageDirection) -> some View {
        self.modifier(BubbleTailViewModifier(direction: direction))
    }
}
