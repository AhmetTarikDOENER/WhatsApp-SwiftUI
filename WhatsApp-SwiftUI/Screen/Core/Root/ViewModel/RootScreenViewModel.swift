import Foundation
import Combine

final class RootScreenViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published private(set) var authState = AuthState.pending
    private var cancellable: AnyCancellable?
    
    //  MARK: - Init
    init() {
        cancellable = AuthenticationService.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                self?.authState = authState
            }
        
        AuthenticationService.testAccounts.forEach { email in
            registerTestAccount(with: email)
        }
    }
    
    private func registerTestAccount(with email: String) {
        Task {
            let username = email.replacingOccurrences(of: "@gmail.com", with: "")
            try? await AuthenticationService.shared.createAccount(for: username, with: email, and: "testUserPassword")
        }
    }
}
