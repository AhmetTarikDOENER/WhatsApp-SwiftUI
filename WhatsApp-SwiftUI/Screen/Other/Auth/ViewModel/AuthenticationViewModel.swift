import Foundation

final class AuthenticationViewModel: ObservableObject {

    //  MARK: - Properties
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var isLoading = false
    
    var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    var disableSignUpButton: Bool {
        disableLoginButton || username.isEmpty
    }
}
