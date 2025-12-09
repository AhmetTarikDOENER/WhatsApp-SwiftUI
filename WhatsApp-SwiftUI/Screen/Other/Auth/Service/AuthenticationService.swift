import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
import StreamVideo

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
    case loginWithEmailFailure(_ description: String)
}

//  MARK: - AuthenticationError+LocalizedDescription
extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailure(let description): return description
        case .savingUserInfoToDatabaseFailure(let description): return description
        case .loginWithEmailFailure(let description): return description
        }
    }
}

//  MARK: - AuthenticationService
final class AuthenticationService: AuthenticationProtocol {
    
    static let shared: AuthenticationProtocol = AuthenticationService()
    private init() { Task { await autoLogin() } }
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    @Published var streamVideo: StreamVideo?
    
    //  MARK: - Internal
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo { [weak self] currentUser in
                self?.setupStreamVideo(currentUser)
            }
            print("✅ AuthenticationService -> Successfully signed in with email: \(authResult.user.email ?? "")")
        } catch {
            print("❌ AuthenticationService -> Failed to sign into the account with email: \(email)")
            throw AuthenticationError.loginWithEmailFailure(error.localizedDescription)
        }
    }
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo { [weak self] currentUser in
                self?.setupStreamVideo(currentUser)
            }
        }
    }
    
    func createAccount(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            setupStreamVideo(newUser)
            try await saveUserInfoToDatabase(user: newUser)
        } catch {
            print("❌ AuthenticationService -> Failed to create user account: \(error.localizedDescription)")
            throw AuthenticationError.accountCreationFailure(error.localizedDescription)
        }
    }
    
    func logOut() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("✅ AuthenticationService -> Successfully logged out")
        } catch {
            print("❌ AuthenticationService -> Failed to log out  current user: \(error.localizedDescription)")
        }
    }
    
    //  MARK: - Private
    private func fetchCurrentUserInfo(completion: @escaping (UserItem) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserReference.child(currentUid)
            .observeSingleEvent(of: .value) { snapshot in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let loggedInUser = UserItem(dictionary: userDictionary)
                completion(loggedInUser)
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
            let userDictionary: [String: Any] = [.uid: user.uid, .username: user.username, .email: user.email]
            
            try await FirebaseConstants.UserReference
                .child(user.uid)
                .setValue(userDictionary)
        } catch {
            print("❌ AuthenticationService -> Failed to save user info to database: \(error.localizedDescription)")
            throw AuthenticationError.savingUserInfoToDatabaseFailure(error.localizedDescription)
        }
    }
}

//  MARK: - AuthenticationService+StreamVideo
extension AuthenticationService {
    private func prepareVideoStream(for currentUser: UserItem) {
        let apiKey = "mmhfdzb5evj2"
        let user = User(id: "Global_Plot", name: "Martin Scorsese")
        let token = UserToken(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")
        streamVideo = StreamVideo(apiKey: apiKey, user: user, token: token)
        print("AuthenticationService -> Stream video setup completed with token: \(token)")
    }
    
    private func setupStreamVideo(_ currentUser: UserItem) {
        prepareVideoStream(for: currentUser)
        authState.send(.loggedIn(currentUser))
    }
}
