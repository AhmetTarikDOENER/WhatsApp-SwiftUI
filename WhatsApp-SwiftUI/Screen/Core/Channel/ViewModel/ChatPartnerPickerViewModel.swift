import Foundation
import FirebaseAuth

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
    private var currentCursor: String?
    
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
    
    //  MARK: - Init
    init() { Task { await fetchUsers() } }
    
    //  MARK: - Internal
    func handleUserSelection(_ user: UserItem) {
        if isUserSelected(user) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == user.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
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
    
    //  MARK: - Private
    func createChannel(_ channelName: String?) -> Result<Channel, Error> {
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
        return .success(newChannel)
    }
    
    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: Channel) -> Void) {
        let channelResult = createChannel(groupName)
        switch channelResult {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            print("❌ ChatPartnerPickerViewModel -> Failed to create group channel: \(error.localizedDescription)")
        }
    }
}
