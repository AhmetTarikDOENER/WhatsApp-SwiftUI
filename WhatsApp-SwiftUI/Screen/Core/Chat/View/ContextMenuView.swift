import SwiftUI

struct ContextMenuView: View {
    
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
