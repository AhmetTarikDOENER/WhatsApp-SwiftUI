import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

//  MARK: - AuthState
enum AuthState {
    case pending, loggedIn, loggedOut
}

//  MARK: - AuthenticationProtocol
protocol AuthenticationProtocol {
    static var shared: AuthenticationProtocol { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    
    func login(with email: String, and password: String) async throws
    func autoLogin() async
    func createAccount(for username: String, with email: String, and password: String) async throws
    func logOut() async throws
}

//  MARK: - AuthenticationService
final class AuthenticationService: AuthenticationProtocol {
    
    static let shared: AuthenticationProtocol = AuthenticationService()
    private init() {  }
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    //  MARK: - Internal
    func login(with email: String, and password: String) async throws {
        
    }
    
    func autoLogin() async {
        
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = authResult.user.uid
        let newUser = UserItem(uid: uid, username: username, email: email)
        try await saveUserInfoToDatabase(user: newUser)
    }
    
    func logOut() async throws {
        
    }
}

extension AuthenticationService {
    private func saveUserInfoToDatabase(user: UserItem) async throws {
        let userDictionary = ["uid": user.uid, "username": user.username, "email": user.email]
        
        try await Database.database().reference()
            .child("users")
            .child(user.uid)
            .setValue(userDictionary)
    }
}
