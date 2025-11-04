import SwiftUI

struct AuthenticationButton: View {
    
    let title: String
    let onTap: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    private var backgroundColor: Color {
        isEnabled ? .white : .white.opacity(0.2)
    }
    
    private var foregroundColor: Color {
        isEnabled ? .green : .white
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(title)
                
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .green.opacity(0.2), radius: 10)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        AuthenticationButton(title: "Login") {
            
        }
    }
}
