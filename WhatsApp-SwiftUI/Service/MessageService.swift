import Foundation
import FirebaseDatabase
import FirebaseFunctions

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
        
        let channelNameAtSend = channel.getPushNotificationTitle(currentUser.username)
        let chatPartnerFcmTokens = channel.membersExcludingMe.compactMap { $0.fcmToken }
        
        let messageDictionary: [String: Any] = [
            .text: textMessage,
            .type: MessageType.text.title,
            .timestamp: timestamp,
            .ownerUid: currentUser.uid,
            .channelNameAtSend: channelNameAtSend,
            .chatPartnerFcmTokens: chatPartnerFcmTokens
        ]
        
        FirebaseConstants.ChannelsReference.child(channel.id).updateChildValues(channelDictionary)
        FirebaseConstants.MessagesReference.child(channel.id).child(messageId).setValue(messageDictionary)
        
        increaseUnreadMessageCountForMembers(in: channel)
        
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
        
        let channelNameAtSend = channel.getPushNotificationTitle(parameters.sender.username)
        
        var messageDictionary: [String: Any] = [
            .text: parameters.text,
            .type: parameters.type.title,
            .timestamp: timestamp,
            .ownerUid: parameters.senderUID,
            .channelNameAtSend: channelNameAtSend,
            .chatPartnerFcmTokens: parameters.chatPartnerFcmTokens
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
        
        increaseUnreadMessageCountForMembers(in: channel)
        
        completion()
    }
    
    static func getHistoricalMessages(
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
                if lastCursor == nil { messages.removeLast() }
                let filteredMessages = lastCursor == nil ? messages : messages.filter { $0.id != lastCursor }
                let messageNode = MessageNode(messages: filteredMessages, lastCursor: first.key)
                completion(messageNode)
            }
        } withCancel: { error in
            print("❌ MessageService -> Failed to get paginated messages: \(error.localizedDescription)")
            completion(.emptyNode)
        }
    }
    
    static func getTheFirstMessage(of channel: Channel, completion: @escaping(Message) -> Void) {
        FirebaseConstants.MessagesReference.child(channel.id)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                dictionary.forEach { key, value in
                    guard let messageDictionary = snapshot.value as? [String: Any] else { return }
                    var firstMessage = Message(id: key, dictionary: messageDictionary, isGroupChat: channel.isGroupChat)
                    let messageSender = channel.members.first { $0.uid == firstMessage.senderUid }
                    firstMessage.sender = messageSender
                    completion(firstMessage)
                }
            } withCancel: { error in
                print("❌ MessageService -> Failed to get the first message: \(error.localizedDescription)")
            }
    }
    
    static func observeForNewMessages(of channel: Channel, completion: @escaping (Message) -> Void) {
        FirebaseConstants.MessagesReference.child(channel.id)
            .queryLimited(toLast: 1)
            .observe(.childAdded) { snapshot in
                guard let messageDictionary = snapshot.value as? [String: Any] else { return }
                var newMessage = Message(id: snapshot.key, dictionary: messageDictionary, isGroupChat: channel.isGroupChat)
                let messageSender = channel.members.first { $0.uid == newMessage.senderUid }
                newMessage.sender = messageSender
                completion(newMessage)
            }
    }
    
    static func increaseCountViaTransaction(at reference: DatabaseReference, completion: ((Int) -> Void)? = nil) {
        reference.runTransactionBlock { currentData in
            if var count = currentData.value as? Int {
                count += 1
                currentData.value = count
            } else {
                currentData.value = 1
            }
            
            completion?(currentData.value as? Int ?? 0)
            
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    static func addReaction(
        reaction: Reaction,
        to message: Message,
        in channel: Channel,
        from currentUser: UserItem,
        completion: @escaping (_ emojiCount: Int) -> Void
    ) {
        let reactionsReference = FirebaseConstants.MessagesReference.child(channel.id).child(message.id).child(.reactions).child(reaction.emoji)
        /// Increase emoji reaction count
        increaseCountViaTransaction(at: reactionsReference) { newEmojiCount in
            /// Add current user's emoji to the related db node
            FirebaseConstants.MessagesReference.child(channel.id).child(message.id)
                .child(.userReactions)
                .child(currentUser.uid)
                .setValue(reaction.emoji)
            
            let channelNameAtSend = channel.getPushNotificationTitle(currentUser.username)
            sendMessageReactionNotification(for: message, emoji: reaction.emoji, channelNameAtSend: channelNameAtSend)
            
            completion(newEmojiCount)
        }
    }
    
    static func sendMessageReactionNotification(for message: Message, emoji: String, channelNameAtSend: String) {
        guard let fcmToken = message.sender?.fcmToken else { return }
        var notificationMessage: String
        if message.type == .text {
            notificationMessage = "Reacted \(emoji) to your \(message.text)"
        } else {
            notificationMessage = "Reacted \(emoji) to your \(message.type.title) message."
        }
        
        let payload: [String: Any] = [
            .fcmToken: fcmToken,
            .channelNameAtSend: channelNameAtSend,
            .notificationMessage: notificationMessage
        ]
        
        Functions.functions().httpsCallable("sendMessageReactionNotification").call(payload) { result, error in
            if let error {
                print("❌ MessageService -> Failed to sendMessageReactionNotification: \(error.localizedDescription)")
            }
        }
    }
    
    static func increaseUnreadMessageCountForMembers(in channel: Channel) {
        let membersUids = channel.membersExcludingMe.map { $0.uid }
        for uid in membersUids {
            let channelUnreadMessageCountRef = FirebaseConstants.UserChannelsReference
                .child(uid)
                .child(channel.id)
            
            increaseCountViaTransaction(at: channelUnreadMessageCountRef)
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
    
    var chatPartnerFcmTokens: [String] { channel.membersExcludingMe.compactMap { $0.fcmToken } }
}

//  MARK: - MessageNode
struct MessageNode {
    var messages: [Message]
    var lastCursor: String?
    
    static let emptyNode = MessageNode(messages: [], lastCursor: nil)
}
