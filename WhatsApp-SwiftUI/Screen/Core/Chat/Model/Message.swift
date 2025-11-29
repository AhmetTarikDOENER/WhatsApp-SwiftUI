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
    let thumbnailURL: String?
    var thumbnailHeight: CGFloat?
    var thumbnailWidth: CGFloat?
    
    var direction: MessageDirection { senderUid == Auth.auth().currentUser?.uid ? .outgoing : .received }
    
    var backgroundColor: Color { direction == .outgoing ? .bubbleGreen : .bubbleWhite }
    
    var alignment: Alignment { direction == .received ? .leading : .trailing }
    
    var horizontalAlignment: HorizontalAlignment { direction == .received ? .leading : .trailing }
    
    var showGroupChatPartnerProfileImage: Bool { isGroupChat && direction == .received }
    
    let horizontalPadding: CGFloat = 25
    
    var leadingPadding: CGFloat { direction == .received ? 0 :  horizontalPadding }
    
    var trailingPadding: CGFloat { direction == .received ? horizontalPadding : 0 }
    
    var imageSize: CGSize {
        let thumbnailWidth = thumbnailWidth ?? 0
        let thumbnailHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(thumbnailHeight / thumbnailWidth * imageWidth)
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
    
    var imageWidth: CGFloat {
        let imageWidth = (UIWindowScene.currentWindowScene?.screenWidth ?? 0) / 1.5
        return imageWidth
    }
}

//  MARK: - Stub Message
extension Message {
    static let sentPlaceholder = Message(
        id: UUID().uuidString,
        text: "Awesome idea!",
        type: .text,
        senderUid: "1",
        timestamp: Date(),
        isGroupChat: true,
        thumbnailURL: nil
    )
    
    static let receivedPlaceholder = Message(
        id: UUID().uuidString,
        text: "Hey Tim, How are you today?",
        type: .text,
        senderUid: "2",
        timestamp: Date(),
        isGroupChat: false,
        thumbnailURL: nil
    )
    
    static let stubMessages: [Message] = [
        .init(id: UUID().uuidString, text: "Hey Tim!", type: .text, senderUid: "3", timestamp: Date(), isGroupChat: true, thumbnailURL: nil),
        .init(id: UUID().uuidString, text: "Did you see this photo?", type: .photo, senderUid: "4", timestamp: Date(), isGroupChat: false, thumbnailURL: nil),
        .init(id: UUID().uuidString, text: "Play out this video", type: .video, senderUid: "5", timestamp: Date(), isGroupChat: false, thumbnailURL: nil),
        .init(id: UUID().uuidString, text: "Listen to this immediately", type: .audio, senderUid: "6", timestamp: Date(), isGroupChat: true, thumbnailURL: nil)
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
        self.thumbnailURL = dictionary[.thumbnailURL] as? String ?? nil
        self.thumbnailWidth = dictionary[.thumbnailWidth] as? CGFloat ?? 0
        self.thumbnailHeight = dictionary[.thumbnailHeight] as? CGFloat ?? 0
    }
}

extension String {
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
}
