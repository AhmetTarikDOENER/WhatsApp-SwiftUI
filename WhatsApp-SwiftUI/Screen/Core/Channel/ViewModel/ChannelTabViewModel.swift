import Foundation
import FirebaseAuth

//  MARK: - ChannelTabRoutes
enum ChannelTabRoutes: Hashable {
    case chatRoom(_ channel: Channel)
}

final class ChannelTabViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var navigateChatroom = false
    @Published var showChatPartnerPickerView = false
    @Published var newChannel: Channel?
    @Published var channels = [Channel]()
    typealias ChannelID = String
    @Published var channelDictionary: [ChannelID: Channel] = [:]
    @Published var navigationRoutes = [ChannelTabRoutes]()
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchCurrentUserChannels()
    }
    
    //  MARK: - Internal & Private
    func onNewChannelCreation(_ channel: Channel) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateChatroom = true
    }
    
    func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsReference.child(currentUid).queryLimited(toLast: 10).observe(.value) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach { key, value in
                let channelId = key
                let unreadMessageCount = value as? Int ?? 0
                self?.getChannel(with: channelId, unreadMessageCount)
            }
        } withCancel: { error in
            print("❌ ChannelTabViewModel -> Failed to get current user's channelIds: \(error.localizedDescription)")
        }
    }
    
    private func getChannel(with channelId: String, _ unreadMessageCount: Int) {
        FirebaseConstants.ChannelsReference.child(channelId).observe(.value) { [weak self] snapshot in
            guard let channelDictionary = snapshot.value as? [String: Any], let self = self else { return }
            var channel = Channel(channelDictionary)
            if let inMemoryCachedChannel = self.channelDictionary[channelId], !inMemoryCachedChannel.members.isEmpty {
                channel.members = inMemoryCachedChannel.members
                channel.unreadMessageCount = unreadMessageCount
                self.channelDictionary[channelId] = channel
                self.reloadChannelData()
                print("⭐️ ChannelTabViewModel -> Get channel members from local stored/cached data for inMemoryCachedChannel: \(channel.title)")
            } else {
                self.getChannelMembers(channel) { members in
                    channel.members = members
                    channel.unreadMessageCount = unreadMessageCount
                    channel.members.append(self.currentUser)
                    self.channelDictionary[channelId] = channel
                    self.reloadChannelData()
                    print("⭐️ ChannelTabViewModel -> Get channel members from database for channel: \(channel.title)")
                }
            }
        } withCancel: { error in
            print("❌ ChannelTabViewModel -> Failed to get the channel for id: \(error.localizedDescription)")
        }
    }
    
    private func getChannelMembers(_ channel: Channel, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let channelMembersUids = Array(channel.membersUids.filter { $0 != currentUid }.prefix(2))
        UserService.getUsers(with: channelMembersUids) { userNode in
            completion(userNode.users)
        }
    }
    
    private func reloadChannelData() {
        self.channels = Array(channelDictionary.values)
        self.channels.sort { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
    }
}
