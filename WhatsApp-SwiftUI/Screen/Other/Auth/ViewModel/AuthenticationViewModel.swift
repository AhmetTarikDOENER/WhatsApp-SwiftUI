import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {

    //  MARK: - Properties
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Opps...Something went wrong!")
    
    var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignUpButton: Bool {
        disableLoginButton || username.isEmpty
    }
    
    //  MARK: - Internal
    func handleSignUp() async {
        isLoading = true
        do {
            try await AuthenticationService.shared.createAccount(for: username, with: email, and: password)
        } catch {
            errorState.errorMessage = "Failed to create an account:\n \(error.localizedDescription)"
            errorState.showError = true
            isLoading = false
        }
    }
}
