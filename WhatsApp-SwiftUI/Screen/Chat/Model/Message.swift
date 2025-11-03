import SwiftUI

struct Message: Identifiable {
    let id = UUID().uuidString
    let text: String
    let direction: MessageDirection
    
    var backgroundColor: Color { direction == .outgoing ? .bubbleGreen : .bubbleWhite }
    
    var alignment: Alignment { direction == .received ? .leading : .trailing }
    
    var horizontalAlignment: HorizontalAlignment { direction == .received ? .leading : .trailing }
    
    static let sentPlaceholder = Message(text: "Awesome idea!", direction: .outgoing)
    static let receivedPlaceholder = Message(text: "Hey Tim, How are you doing?", direction: .received)
}

//  MARK: - MessageDirection
enum MessageDirection {
    case outgoing, received
    
    static var random: MessageDirection {
        return [.outgoing, .received].randomElement() ?? .outgoing
    }
}
