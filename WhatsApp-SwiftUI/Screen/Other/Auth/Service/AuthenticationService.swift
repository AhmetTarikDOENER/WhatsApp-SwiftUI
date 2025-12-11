import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
import StreamVideo
import FirebaseFunctions

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
    func getStreamUserToken(for userId: String) async -> UserToken?
    func revokeStreamUserToken() async
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
    private lazy var functions = Functions.functions()
    
    //  MARK: - Internal
    func login(with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let streamToken = await getStreamUserToken(for: authResult.user.uid)
            fetchCurrentUserInfo { [weak self] currentUser in
                var updatedUser = currentUser
                updatedUser.streamToken = streamToken?.rawValue
                self?.setupStreamVideo(currentUser)
            }
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
            var newUser = UserItem(uid: uid, username: username, email: email)
            setupStreamVideo(newUser)
            let streamToken = await getStreamUserToken(for: authResult.user.uid)
            newUser.streamToken = streamToken?.rawValue
            try await saveUserInfoToDatabase(user: newUser)
        } catch {
            print("❌ AuthenticationService -> Failed to create user account: \(error.localizedDescription)")
            throw AuthenticationError.accountCreationFailure(error.localizedDescription)
        }
    }
    
    func logOut() async throws {
        do {
            await revokeStreamUserToken()
            streamVideo = nil
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("✅ AuthenticationService -> Successfully logged out")
        } catch {
            print("❌ AuthenticationService -> Failed to log out  current user: \(error.localizedDescription)")
        }
    }
    
    func getStreamUserToken(for userId: String) async -> UserToken? {
        do {
            let getStreamUserToken = try await functions.httpsCallable(GCFunctionsConfig.getStreamUserToken).call()
            guard let currentUserStreamToken = getStreamUserToken.data as? String else { return nil }
            let streamToken = UserToken(rawValue: currentUserStreamToken)
            print("Successfully fired getStreamUserToken function: \(currentUserStreamToken)")
            streamToken.storeStreamToken(for: userId)
            return streamToken
        } catch {
            print("❌ AuthenticationService -> Failed to get stream user token: \(error.localizedDescription)")
            return nil
        }
    }
    
    func revokeStreamUserToken() async {
        do {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            _ = try await functions.httpsCallable(GCFunctionsConfig.revokeStreamUserToken).call()
            try await FirebaseConstants.UserReference.child(currentUid).child(.streamToken).removeValue()
        } catch {
            print("❌ AuthenticationService -> Failed to revoke stream user token: \(error.localizedDescription)")
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
        guard streamVideo == nil else { return }
        let apiKey = VideoStreamConfig.videoStreamAPIKey
        let streamUser = User(
            id: currentUser.uid,
            name: currentUser.username,
            imageURL: URL(string: currentUser.profileImageURL ?? "")
        )
        guard let streamToken = currentUser.streamToken else { return }
        streamVideo = StreamVideo(apiKey: apiKey, user: streamUser, token: UserToken(rawValue: streamToken))
    }
    
    private func setupStreamVideo(_ currentUser: UserItem) {
        prepareVideoStream(for: currentUser)
        authState.send(.loggedIn(currentUser))
    }
}

//  MARK: - UserToken
private extension UserToken {
    func storeStreamToken(for userId: String) {
        FirebaseConstants.UserReference
            .child(userId)
            .child(.streamToken)
            .setValue(self.rawValue)
    }
}
