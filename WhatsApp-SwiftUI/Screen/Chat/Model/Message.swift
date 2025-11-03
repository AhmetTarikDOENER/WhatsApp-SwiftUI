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
        .init(text: "Play out this video", direction: .outgoing, type: .video)
    ]
}

//  MARK: - MessageDirection
enum MessageDirection {
    case outgoing, received
    
    static var random: MessageDirection {
        return [.outgoing, .received].randomElement() ?? .outgoing
    }
}

//  MARK: - MessageType
enum MessageType {
    case text, photo, video
}
