import Foundation
import FirebaseAuth
import Combine

//  MARK: - ChannelCreationRoute
enum ChannelCreationRoute {
    case groupChatPartnerPicker
    case setupGroupChat
}

//  MARK: - ChannelConstants
enum ChannelConstants {
    static let maxGroupParticipantCount = 12
}

enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}

//  MARK: - ChatPartnerPickerViewModel
@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var navigationStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published private(set) var users: [UserItem] = []
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Oh no! Something went wrong.")
    private var currentCursor: String?
    private var currentUser: UserItem?
    private var subscription: AnyCancellable?
    
    var showSelectedUsers: Bool {
        !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        selectedChatPartners.isEmpty
    }
    
    var isPaginatable: Bool {
        !users.isEmpty
    }
    
    private var isDirectChannel: Bool {
        selectedChatPartners.count == 1
    }
    
    //  MARK: - Init & Deinit
    init() {
        listenForAuthState()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    //  MARK: - Internal & Private
    func handleUserSelection(_ user: UserItem) {
        if isUserSelected(user) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == user.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            guard selectedChatPartners.count < ChannelConstants.maxGroupParticipantCount else {
                let errorMessage = "Sorry, you can only invite up to \(ChannelConstants.maxGroupParticipantCount) people to a group chat."
                showError(errorMessage)
                return
            }
            
            selectedChatPartners.append(user)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(currentCursor: currentCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            self.users.append(contentsOf: fetchedUsers)
            self.currentCursor = userNode.currentCursor
            print("✅ ChatPartnerPickerViewModel -> currentCursor: \(String(describing: currentCursor)) with \(users.count)")
        } catch {
            print("❌ ChatPartnerPickerViewModel -> Failed to fetch users: \(error.localizedDescription)")
        }
    }
    
    private func listenForAuthState() {
        subscription = AuthenticationService.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                switch authState {
                case .loggedIn(let loggedInUser):
                    self?.currentUser = loggedInUser
                    Task { await self?.fetchUsers() }
                default: break
                }
            }
    }
    
    private func createChannel(_ channelName: String?) -> Result<Channel, Error> {
        guard !selectedChatPartners.isEmpty else { return .failure(ChannelCreationError.noChatPartner)}
        guard let channelId = FirebaseConstants.ChannelsReference.childByAutoId().key,
              let currentUid = Auth.auth().currentUser?.uid,
              let messageId = FirebaseConstants.MessagesReference.childByAutoId().key else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds)
        }
        
        let timestamp = Date().timeIntervalSince1970
        
        var membersUids = selectedChatPartners.compactMap { $0.uid }
        membersUids.append(currentUid)
        
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        
        var channelDictionary: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .creationDate: timestamp,
            .lastMessageTimestamp: timestamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhitespace {
            channelDictionary[.name] = channelName
        }
 
        let messageDictionary: [String: Any] = [
            .type: newChannelBroadcast,
            .timestamp: timestamp,
            .ownerUid: currentUid
        ]
        
        FirebaseConstants.ChannelsReference.child(channelId).setValue(channelDictionary)
        FirebaseConstants.MessagesReference.child(channelId).child(messageId).setValue(messageDictionary)
        
        membersUids.forEach { userId in
            FirebaseConstants.UserChannelsReference.child(userId).child(channelId).setValue(true)
        }
        
        if isDirectChannel {
            let chatPartner = selectedChatPartners[0]
            FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannels.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
        }
        
        var newChannel = Channel(channelDictionary)
        newChannel.members = selectedChatPartners
        if let currentUser {
            newChannel.members.append(currentUser)
        }
        return .success(newChannel)
    }
    
    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: Channel) -> Void) {
        let channelResult = createChannel(groupName)
        switch channelResult {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            showError("Sorry, could not create a group channel. Please try again later.")
            print("❌ ChatPartnerPickerViewModel -> Failed to create group channel: \(error.localizedDescription)")
        }
    }
    
    func deselectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.selectedChatPartners.removeAll()
        }
    }
    
    func createDirectChannel(_ chatPartner: UserItem, completion: @escaping (_ newChannel: Channel) -> Void) {
        selectedChatPartners.append(chatPartner)
        Task {
            /// If direct channel already exists, get the channel
            if let channelId = await existingDirectChannel(with: chatPartner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsReference.child(channelId).getData()
                var channelDictionary = snapshot.value as! [String: Any]
                var directChannel = Channel(channelDictionary)
                directChannel.members = selectedChatPartners
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                completion(directChannel)
                print("♦️ ChatPartnerPickerViewModel -> Direct Channel already exists, fetched from db.")
            } else {
                /// Create a new direct channel with the user.
                let channelResult = createChannel(nil)
                switch channelResult {
                case .success(let channel):
                    completion(channel)
                case .failure(let error):
                    showError("Sorry, could not create a direct channel. Please try again later.")
                    print("❌ ChatPartnerPickerViewModel -> Failed to create a direct channel: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
    
    typealias ExistedChannelID = String
    private func existingDirectChannel(with chatPartnerId: String) async -> ExistedChannelID? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists() else { return nil }
        
        let directMessageDictionary = snapshot.value as! [String: Bool]
        let channelId = directMessageDictionary.compactMap { $0.key }.first
        
        return channelId
    }
}
