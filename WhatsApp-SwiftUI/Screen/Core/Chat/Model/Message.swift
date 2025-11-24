import SwiftUI
import FirebaseAuth

struct Message: Identifiable {
    let id: String
    let text: String
    let type: MessageType
    let senderUid: String
    let timestamp: Date
    let isGroupChat: Bool
    var sender: UserItem?
    
    var direction: MessageDirection { senderUid == Auth.auth().currentUser?.uid ? .outgoing : .received }
    
    var backgroundColor: Color { direction == .outgoing ? .bubbleGreen : .bubbleWhite }
    
    var alignment: Alignment { direction == .received ? .leading : .trailing }
    
    var horizontalAlignment: HorizontalAlignment { direction == .received ? .leading : .trailing }
    
    var showGroupChatPartnerProfileImage: Bool { isGroupChat && direction == .received }
    
    let horizontalPadding: CGFloat = 25
    
    var leadingPadding: CGFloat { direction == .received ? 0 :  horizontalPadding }
    
    var trailingPadding: CGFloat { direction == .received ? horizontalPadding : 0 }
}

//  MARK: - Stub Message
extension Message {
    static let sentPlaceholder = Message(
        id: UUID().uuidString,
        text: "Awesome idea!",
        type: .text,
        senderUid: "1",
        timestamp: Date(),
        isGroupChat: true
    )
    
    static let receivedPlaceholder = Message(
        id: UUID().uuidString,
        text: "Hey Tim, How are you today?",
        type: .text,
        senderUid: "2",
        timestamp: Date(),
        isGroupChat: false
    )
    
    static let stubMessages: [Message] = [
        .init(id: UUID().uuidString, text: "Hey Tim!", type: .text, senderUid: "3", timestamp: Date(), isGroupChat: true),
        .init(id: UUID().uuidString, text: "Did you see this photo?", type: .photo, senderUid: "4", timestamp: Date(), isGroupChat: false),
        .init(id: UUID().uuidString, text: "Play out this video", type: .video, senderUid: "5", timestamp: Date(), isGroupChat: false),
        .init(id: UUID().uuidString, text: "Listen to this immediately", type: .audio, senderUid: "6", timestamp: Date(), isGroupChat: true)
    ]
}

extension Message {
    init(id: String, dictionary: [String: Any], isGroupChat: Bool) {
        self.id = id
        self.text = dictionary[.text] as? String ?? ""
        let type = dictionary[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        self.senderUid = dictionary[.ownerUid] as? String ?? ""
        let timeInterval = dictionary[.timestamp] as? TimeInterval ?? 0
        self.timestamp = Date(timeIntervalSince1970: timeInterval)
        self.isGroupChat = isGroupChat
    }
}

extension String {
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
}
