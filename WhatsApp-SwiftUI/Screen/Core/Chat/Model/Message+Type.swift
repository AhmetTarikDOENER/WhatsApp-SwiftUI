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
enum MessageType: Hashable {
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
    
    var iconName: String {
        switch self {
        case .admin: return "megaphone.fill"
        case .text: return ""
        case .photo: return "photo.fill"
        case .video: return "video.fill"
        case .audio: return "mic.fill"
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

//  MARK: - Reactions
enum Reaction: Int {
    case like
    case heart
    case laugh
    case shocked
    case sad
    case pray
    case more
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .heart: return "♥️"
        case .laugh: return "😀"
        case .shocked: return "😮"
        case .sad: return "☹️"
        case .pray: return "🙏"
        case .more: return "➕"
        }
    }
}
