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
    
    var title: String {
        switch self {
        case .text: return "text"
        case .photo: return "photo"
        case .video: return "video"
        case .audio: return "audio"
        }
    }
}
