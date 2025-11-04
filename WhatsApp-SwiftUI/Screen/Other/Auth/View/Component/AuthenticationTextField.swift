import SwiftUI

struct AuthenticationTextField: View {
    
    @Binding var text: String
    
    let type: InputType
    
    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)
            
            switch type {
            case .password: SecureField(type.placeholder, text: $text)
            default: TextField(type.placeholder, text: $text)
                    .keyboardType(type.keyboardType)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

//  MARK: - AuthenticationTextField
extension AuthenticationTextField {
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, iconName: String)
        
        var placeholder: String {
            switch self {
            case .email: return "Email"
            case .password: return "Password"
            case .custom(let placeholder, _): return placeholder
            }
        }
        
        var imageName: String {
            switch self {
            case .email: return "envelope"
            case .password: return "lock"
            case .custom(_, let iconName): return iconName
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email: .emailAddress
            default: .default
            }
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthenticationTextField(text: .constant(""), type: .email)
            AuthenticationTextField(text: .constant(""), type: .password)
            AuthenticationTextField(text: .constant(""), type: .custom("Birthday", iconName: "birthday.cake"))
        }
    }
}
