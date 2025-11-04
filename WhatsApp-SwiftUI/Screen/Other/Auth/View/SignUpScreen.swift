import SwiftUI

struct SignUpScreen: View {
    
    //  MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            AuthenticationLogoView()
            
            AuthenticationTextField(text: $authViewModel.email, type: .email)
            
            let userNameInputType = AuthenticationTextField.InputType.custom(
                "Username",
                iconName: "at"
            )
            AuthenticationTextField(text: $authViewModel.username, type: userNameInputType)
            
            AuthenticationTextField(text: $authViewModel.password, type: .password)
            
            AuthenticationButton(title: "Create an Account") {
                Task { await authViewModel.handleSignUp() }
            }
            .disabled(authViewModel.disableSignUpButton)
            
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
    
    //  MARK: - Private
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
    SignUpScreen(authViewModel: .init())
}
