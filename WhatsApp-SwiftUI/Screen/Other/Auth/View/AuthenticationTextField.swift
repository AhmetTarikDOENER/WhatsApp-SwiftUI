import SwiftUI

struct AuthenticationTextField: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "envelope")
                .fontWeight(.semibold)
                .frame(width: 30)
            
            TextField("Email", text: $text)
        }
        .foregroundStyle(.white)
        .padding()
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

#Preview {
    ZStack {
        Color.teal
        AuthenticationTextField(text: .constant(""))
    }
}
