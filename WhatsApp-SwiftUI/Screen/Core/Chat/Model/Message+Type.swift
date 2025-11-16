import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberRemoved
    case channelNameChanged
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
    case text, photo, video, audio
}
