import Foundation
import FirebaseDatabase

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
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.text.title
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
                var message = Message(id: key, dictionary: messageDictionary, isGroupChat: channel.isGroupChat)
                let messageSender = channel.members.first { $0.uid == message.senderUid }
                message.sender = messageSender
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
    
    static func sendMediaMessage(
        to channel: Channel,
        parameters: MediaMessageUploadParameters,
        completion: @escaping () -> Void
    ) {
        guard let messageId = FirebaseConstants.MessagesReference.childByAutoId().key else { return }
        let timestamp = Date().timeIntervalSince1970
        
        let channelDictionary: [String: Any] = [
            .lastMessage: parameters.text,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: parameters.type.title
        ]
        
        var messageDictionary: [String: Any] = [
            .text: parameters.text,
            .type: parameters.type.title,
            .timestamp: timestamp,
            .ownerUid: parameters.senderUID
        ]
        /// Photo Messages
        messageDictionary[.thumbnailURL] = parameters.thumbnailURL ?? nil
        messageDictionary[.thumbnailWidth] = parameters.thumbnailWidth ?? nil
        messageDictionary[.thumbnailHeight] = parameters.thumbnailHeight ?? nil
        /// Video Messages
        messageDictionary[.videoURL] = parameters.videoURL ?? nil
        /// Audio Messages
        messageDictionary[.audioURL] = parameters.audioURL ?? nil
        messageDictionary[.audioDuration] = parameters.audioDuration ?? nil
        
        FirebaseConstants.ChannelsReference.child(channel.id).updateChildValues(channelDictionary)
        FirebaseConstants.MessagesReference.child(channel.id).child(messageId).setValue(messageDictionary)
        
        completion()
    }
    
    static func getPaginatedMessages(
        for channel: Channel,
        lastCursor: String?,
        pageSize: UInt,
        completion: @escaping (MessageNode) -> Void
    ) {
        let query: DatabaseQuery
        
        if lastCursor == nil {
            query = FirebaseConstants.MessagesReference.child(channel.id).queryLimited(toLast: pageSize)
        } else {
            query = FirebaseConstants.MessagesReference.child(channel.id)
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toFirst: pageSize)
        }
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = snapshot.children.allObjects as? [DataSnapshot]  else { return }
            
            var messages: [Message] = allObjects.compactMap { messageSnapshot in
                let messageDictionary = messageSnapshot.value as? [String: Any] ?? [:]
                var message = Message(
                    id: messageSnapshot.key,
                    dictionary: messageDictionary,
                    isGroupChat: channel.isGroupChat
                )
                
                let messageSender = channel.members.first { $0.uid == message.senderUid }
                message.sender = messageSender
                
                return message
            }
            messages.sort { $0.timestamp < $1.timestamp }
            
            if messages.count == snapshot.childrenCount {
                let messageNode = MessageNode(messages: messages, lastCursor: first.key)
                completion(messageNode)
            }
        } withCancel: { error in
            print("❌ MessageService -> Failed to get paginated messages: \(error.localizedDescription)")
            completion(.emptyNode)
        }
    }
}

//  MARK: - MediaMessageUploadParameters
struct MediaMessageUploadParameters {
    let channel: Channel
    let text: String
    let type: MessageType
    let attachment: MediaAttachments
    var thumbnailURL: String?
    var videoURL: String?
    let sender: UserItem
    var audioURL: String?
    var audioDuration: TimeInterval?
    
    var senderUID: String { sender.uid }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .video else { return nil }
        return attachment.thumbnail.size.height
    }
}

//  MARK: - MessageNode
struct MessageNode {
    var messages: [Message]
    var lastCursor: String?
    
    static let emptyNode = MessageNode(messages: [], lastCursor: nil)
}
