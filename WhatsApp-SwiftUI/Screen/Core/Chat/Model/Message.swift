import SwiftUI
import FirebaseAuth

struct Message: Identifiable {
    let id: String
    let text: String
    let type: MessageType
    let senderUid: String
    
    var direction: MessageDirection { senderUid == Auth.auth().currentUser?.uid ? .outgoing : .received }
    
    var backgroundColor: Color { direction == .outgoing ? .bubbleGreen : .bubbleWhite }
    
    var alignment: Alignment { direction == .received ? .leading : .trailing }
    
    var horizontalAlignment: HorizontalAlignment { direction == .received ? .leading : .trailing }
}

//  MARK: - Stub Message
extension Message {
    static let sentPlaceholder = Message(
        id: UUID().uuidString,
        text: "Awesome idea!",
        type: .text,
        senderUid: "1"
    )
    
    static let receivedPlaceholder = Message(
        id: UUID().uuidString,
        text: "Hey Tim, How are you today?",
        type: .text,
        senderUid: "2"
    )
    
    static let stubMessages: [Message] = [
        .init(id: UUID().uuidString, text: "Hey Tim!", type: .text, senderUid: "3"),
        .init(id: UUID().uuidString, text: "Did you see this photo?", type: .photo, senderUid: "4"),
        .init(id: UUID().uuidString, text: "Play out this video", type: .video, senderUid: "5"),
        .init(id: UUID().uuidString, text: "Listen to this immediately", type: .audio, senderUid: "6")
    ]
}

extension Message {
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.text = dictionary[.text] as? String ?? ""
        let type = dictionary[.type] as? String ?? "text"
        self.type = MessageType(type)
        self.senderUid = dictionary[.ownerUid] as? String ?? ""
    }
}

extension String {
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
}
