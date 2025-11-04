import SwiftUI

struct LoginScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                AuthenticationLogoView()
                
                AuthenticationTextField(text: .constant(""), type: .email)
                AuthenticationTextField(text: .constant(""), type: .password)
                
                forgotPasswordButton()
                
                AuthenticationButton(title: "Login Now") {
                    
                }
                
                Spacer()
                
                signUpButton()
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.teal.gradient)
            .ignoresSafeArea()
        }
    }
    
    //  MARK: - Private
    private func forgotPasswordButton() -> some View {
        Button {
            
        } label: {
            Text("Forgot Password?")
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 32)
                .bold()
                .padding(.vertical)
        }
    }
    
    private func signUpButton() -> some View {
        NavigationLink {
            SignUpScreen()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                
                Text("Don't have an account ? ") +
                Text("Create one").bold()
                
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    LoginScreen()
}
