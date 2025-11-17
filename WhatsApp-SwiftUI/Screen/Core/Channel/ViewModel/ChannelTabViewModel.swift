import Foundation
import FirebaseAuth

final class ChannelTabViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var navigateChatroom = false
    @Published var showChatPartnerPickerView = false
    @Published var newChannel: Channel?
    @Published var channels = [Channel]()
    
    init() {
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
        FirebaseConstants.UserChannelsReference.child(currentUid).observe(.value) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            dictionary.forEach { key, value in
                let channelId = key
                self?.getChannel(with: channelId)
            }
        } withCancel: { error in
            print("❌ ChannelTabViewModel -> Failed to get current user's channelIds: \(error.localizedDescription)")
        }
    }
    
    private func getChannel(with channelId: String) {
        FirebaseConstants.ChannelsReference.child(channelId).observe(.value) { [weak self] snapshot in
            guard let channelDictionary = snapshot.value as? [String: Any] else { return }
            var channel = Channel(channelDictionary)
            self?.getChannelMembers(channel) { members in
                channel.members = members
                self?.channels.append(channel)
                print("⭐️ ChannelTabViewModel -> Appended channel with title: \(channel.title)")
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
}
