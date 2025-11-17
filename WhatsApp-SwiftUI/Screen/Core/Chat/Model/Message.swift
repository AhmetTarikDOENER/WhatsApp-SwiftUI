import SwiftUI

struct Message: Identifiable {
    let id = UUID().uuidString
    let text: String
    let direction: MessageDirection
    let type: MessageType
    
    var backgroundColor: Color { direction == .outgoing ? .bubbleGreen : .bubbleWhite }
    
    var alignment: Alignment { direction == .received ? .leading : .trailing }
    
    var horizontalAlignment: HorizontalAlignment { direction == .received ? .leading : .trailing }
}

//  MARK: - Stub Message
extension Message {
    static let sentPlaceholder = Message(
        text: "Awesome idea!",
        direction: .outgoing,
        type: .text
    )
    
    static let receivedPlaceholder = Message(
        text: "Hey Tim, How are you doing?",
        direction: .received,
        type: .text
    )
    
    static let stubMessages: [Message] = [
        .init(text: "Hey Tim!", direction: .outgoing, type: .text),
        .init(text: "Did you see this photo?", direction: .received, type: .photo),
        .init(text: "Play out this video", direction: .outgoing, type: .video),
        .init(text: "Listen to this immediately", direction: .received, type: .audio)
    ]
}

extension String {
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
}
