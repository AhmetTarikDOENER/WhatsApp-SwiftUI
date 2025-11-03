import SwiftUI

struct BubbleTextView: View {
    
    let message: Message
    
    var body: some View {
        VStack(alignment: message.horizontalAlignment, spacing: 3) {
            Text("Hello, Tim! How ya doing?")
                .padding(10)
                .background(message.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .applyTail(message.direction)
            
            timestampTextView()
        }
        .shadow(
            color: Color(.systemGray3).opacity(0.1),
            radius: 5,
            x: 0,
            y: 20
        )
        .frame(maxWidth: .infinity, alignment: message.alignment)
        .padding(.leading, message.direction == .received ? 5 : 100)
        .padding(.trailing, message.direction == .received ? 100 : 5)
    }
    
    //  MARK: - Private
    private func timestampTextView() -> some View {
        HStack {
            Text("05:06 PM")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            
            if message.direction == .outgoing {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color(.systemBlue))
            }
        }
    }
}

#Preview {
    ScrollView {
        BubbleTextView(message: .sentPlaceholder)
        BubbleTextView(message: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .background(.green.opacity(0.1))
}
