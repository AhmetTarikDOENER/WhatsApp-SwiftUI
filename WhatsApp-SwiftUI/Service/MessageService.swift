import Foundation

struct MessageService {
    
    static func sendTextMessage(
        to channel: Channel,
        from currentUser: UserItem,
        _ textMessage: String,
        onComplete: () -> Void
    ) {
        guard let messageId = FirebaseConstants.MessagesReference.childByAutoId().key else { return }
        let timestamp = Date().timeIntervalSince1970
        let channelDictionary: [String: Any] = [
            .lastMessage: textMessage,
            .lastMessageTimestamp: timestamp
        ]
        
        let messageDictionary: [String: Any] = [
            .text: textMessage,
            .type: MessageType.text.title,
            .timestamp: timestamp,
            .ownerUid: currentUser.uid
        ]
        
        FirebaseConstants.ChannelsReference.child(channel.id).updateChildValues(channelDictionary)
        FirebaseConstants.MessagesReference.child(channel.id).child(messageId).setValue(messageDictionary)
        
        onComplete()
    }
    
    static func getMessages(
        for channel: Channel,
        completion: @escaping ([Message]) -> Void
    ) {
        FirebaseConstants.MessagesReference.child(channel.id).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            var messages: [Message] = []
            dictionary.forEach { key, value in
                let messageDictionary = value as? [String: Any] ?? [:]
                let message = Message(id: key, dictionary: messageDictionary, isGroupChat: channel.isGroupChat)
                messages.append(message)
                if messages.count == snapshot.childrenCount {
                    messages.sort { $0.timestamp < $1.timestamp }
                    completion(messages)
                }
            }
        } withCancel: { error in
            print("❌ MessageService -> Failed to get messages for channel: \(error.localizedDescription)")
        }
    }
}
