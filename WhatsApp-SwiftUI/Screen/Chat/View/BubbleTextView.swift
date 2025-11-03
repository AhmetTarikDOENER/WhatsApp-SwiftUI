import SwiftUI

struct BubbleTextView: View {
    var body: some View {
        Text("Hello, Tim! How ya doing?")
            .padding(10)
            .background(.bubbleGreen)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    BubbleTextView()
}
