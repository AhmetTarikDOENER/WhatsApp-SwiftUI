import SwiftUI

struct ChannelCreationTextView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color { colorScheme == .dark ? .black : .yellow }
    
    var body: some View {
        ZStack(alignment: .top) {
            Text(Image(systemName: "lock.fill")) +
            Text(" Messages and calls are end-to-end encrypted, so no one outside of this chat, not even WhatsApp itself, can read or listen in.") +
            Text(" Learn more")
                .bold()
        }
        .font(.footnote)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

#Preview {
    ChannelCreationTextView()
}
