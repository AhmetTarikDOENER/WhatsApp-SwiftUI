import Foundation

//  MARK: - AdminMessageType
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
    case admin(_ adminMessageType: AdminMessageType), text, photo, video, audio
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "text": self = .text
        case "photo": self = .photo
        case "video": self = .video
        case "audio": self = .audio
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
    
    var title: String {
        switch self {
        case .admin: return "admin"
        case .text: return "text"
        case .photo: return "photo"
        case .video: return "video"
        case .audio: return "audio"
        }
    }
}

extension MessageType: Equatable {
    static func ==(lhs: MessageType, rhs: MessageType) -> Bool {
        switch (lhs, rhs) {
        case(.admin(let leftAdmin), .admin(let rightAdmin)):
            return leftAdmin == rightAdmin
        case (.text, .text),
             (.photo, .photo),
             (.video, .video),
             (.audio, .audio):
            return true
        default:
            return false
        }
    }
}
