import SwiftUI

struct BubbleTextView: View {
    
    let message: Message
    
    var body: some View {
        Text("Hello, Tim! How ya doing?")
            .padding(10)
            .background(message.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .applyTail(message.direction)
    }
}

#Preview {
    ScrollView {
        BubbleTextView(message: .sentPlaceholder)
        BubbleTextView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(.black.opacity(0.5))
}
