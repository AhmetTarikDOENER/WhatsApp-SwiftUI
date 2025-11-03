import Foundation

struct Message: Identifiable {
    let id = UUID().uuidString
    let text: String
    let direction: MessageDirection
}

//  MARK: - MessageDirection
enum MessageDirection {
    case outgoing, received
    
    static var random: MessageDirection {
        return [.outgoing, .received].randomElement() ?? .outgoing
    }
}
