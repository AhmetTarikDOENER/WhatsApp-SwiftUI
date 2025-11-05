import SwiftUI

struct LoginScreen: View {
    
    //  MARK: - Properties
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                AuthenticationLogoView()
                
                AuthenticationTextField(text: $authViewModel.email, type: .email)
                AuthenticationTextField(text: $authViewModel.password, type: .password)
                
                forgotPasswordButton()
                
                AuthenticationButton(title: "Login Now") {
                    Task { await authViewModel.handleLogin() }
                }
                .disabled(authViewModel.disableLoginButton)
                
                Spacer()
                
                signUpButton()
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.teal.gradient)
            .ignoresSafeArea()
            .alert(isPresented: $authViewModel.errorState.showError) {
                Alert(
                    title: Text(authViewModel.errorState.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
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
            SignUpScreen(authViewModel: authViewModel)
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
