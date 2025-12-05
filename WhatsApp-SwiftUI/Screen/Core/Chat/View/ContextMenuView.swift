import SwiftUI

struct ContextMenuView: View {

    @State private var animateBackground = false
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(ContextMenuAction.allCases) { action in
                buttonLabel(action)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(action.rawValue == "delete" ? .red : .whatsAppBlack)
                
                if action != .delete {
                    Divider()
                }
            }
        }
        .frame(width: message.imageWidth)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(animateBackground ? 1.0 : 0.0, anchor: message.menuAnchor)
        .opacity(animateBackground ? 1.0 : 0.0)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                animateBackground = true
            }
        }
    }
    
    //  MARK: - Private
    private func buttonLabel(_ action: ContextMenuAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Text(action.rawValue.capitalized)
                
                Spacer()
                
                Image(systemName: action.systemImageName)
            }
            .padding()
        }
    }
}

#Preview {
    ContextMenuView(message: .receivedPlaceholder)
}
