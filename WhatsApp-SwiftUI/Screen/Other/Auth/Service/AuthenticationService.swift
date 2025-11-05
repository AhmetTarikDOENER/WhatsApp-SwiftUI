import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

//  MARK: - AuthState
enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
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

//  MARK: - AuthenticationError
enum AuthenticationError: Error {
    case accountCreationFailure(_ description: String)
    case savingUserInfoToDatabaseFailure(_ description: String)
}

//  MARK: - AuthenticationError+LocalizedDescription
extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailure(let description): return description
        case .savingUserInfoToDatabaseFailure(let description): return description
        }
    }
}

//  MARK: - AuthenticationService
final class AuthenticationService: AuthenticationProtocol {
    
    static let shared: AuthenticationProtocol = AuthenticationService()
    private init() { Task { await autoLogin() } }
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    //  MARK: - Internal
    func login(with email: String, and password: String) async throws {
        
    }
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            self.authState.send(.loggedIn(newUser))
            try await saveUserInfoToDatabase(user: newUser)
        } catch {
            print("🔒 AuthenticationService -> Failed to create user account: \(error.localizedDescription)")
            throw AuthenticationError.accountCreationFailure(error.localizedDescription)
        }
    }
    
    func logOut() async throws {
        
    }
    
    //  MARK: - Private
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users")
            .child(currentUid)
            .observe(.value) { [weak self] snapshot in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let loggedInUser = UserItem(dictionary: userDictionary)
                self?.authState.send(.loggedIn(loggedInUser))
                print("✅ AuthenticationService -> Successfully fetched current user \(loggedInUser.username) info from database")
            } withCancel: { error in
                print("❌ AuthenticationService -> Failed to get current user info from database: \(error.localizedDescription)")
            }
    }
}

//  MARK: - AuthenticationService+Extension
extension AuthenticationService {
    private func saveUserInfoToDatabase(user: UserItem) async throws {
        do {
            let userDictionary = ["uid": user.uid, "username": user.username, "email": user.email]
            
            try await Database.database().reference()
                .child("users")
                .child(user.uid)
                .setValue(userDictionary)
        } catch {
            print("❌ AuthenticationService -> Failed to save user info to database: \(error.localizedDescription)")
            throw AuthenticationError.savingUserInfoToDatabaseFailure(error.localizedDescription)
        }
    }
}
