import SwiftUI

struct SignUpScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            AuthenticationLogoView()
            
            AuthenticationTextField(text: .constant(""), type: .email)
            
            let userNameInputType = AuthenticationTextField.InputType.custom(
                "Username",
                iconName: "at"
            )
            AuthenticationTextField(text: .constant(""), type: userNameInputType)
            
            AuthenticationTextField(text: .constant(""), type: .password)
            
            AuthenticationButton(title: "Create an Account") {
                
            }
            
            Spacer()
            
            backButton()
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            LinearGradient(
                colors: [.green, .green.opacity(0.75), .teal],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
    
    private func backButton() -> some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                
                Text("Already created an account ? ") +
                Text("Log in").bold()
                
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SignUpScreen()
}
