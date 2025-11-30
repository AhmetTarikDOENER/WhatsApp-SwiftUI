import Foundation
import FirebaseAuth

struct Channel: Identifiable, Hashable {
    var id: String
    var name: String?
    private var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    private var thumbnailURL: String?
    let createdBy: String
    let lastMessageType: MessageType
    
    var isGroupChat: Bool { membersCount > 2 }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }
    
    var title: String {
        if let name = name { return name }
        
        if isGroupChat {
            return groupMembersNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }
    
    private var groupMembersNames: String {
        let membersCount = membersCount - 1
        let fullNames: [String] = membersExcludingMe.map { $0.username }
        
        if membersCount == 2 {
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + ", and \(remainingCount) " + "others"
        }
        
        return "Unknown"
    }
    
    var isCreatedByMe: Bool { createdBy == Auth.auth().currentUser?.uid ?? "" }
    
    var creatorName: String { members.first { $0.uid == createdBy }?.username ?? "Someone" }
    
    var circularProfileImageURL: String? {
        if let thumbnailUrl = thumbnailURL { return thumbnailUrl }
        
        if isGroupChat == false { return membersExcludingMe.first?.profileImageURL }
        
        return nil
    }
    
    var allMembersFetched: Bool { members.count == membersCount }
    
    var messagePreview: String {
        switch lastMessageType {
        case .admin: return "Be the first who send a message to this newly created group"
        case .text: return lastMessage
        case .photo: return "Photo Message"
        case .video: return "Video Message"
        case .audio: return "Audio Message"
        }
    }
}

extension Channel {
    init(_ dictionary: [String: Any]) {
        self.id = dictionary[.id] as? String ?? ""
        self.name = dictionary[.name] as? String? ?? nil
        self.lastMessage = dictionary[.lastMessage] as? String ?? ""
        
        let creationInterval = dictionary[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        
        let lastMessageInterval = dictionary[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMessageInterval)
        
        self.membersCount = dictionary[.membersCount] as? Int ?? 0
        self.adminUids = dictionary[.adminUids] as? [String] ?? []
        self.thumbnailURL = dictionary[.thumbnailURL] as? String? ?? nil
        self.membersUids = dictionary[.membersUids] as? [String] ?? []
        self.members = dictionary[.members] as? [UserItem] ?? []
        self.createdBy = dictionary[.createdBy] as? String ?? ""
        let messageTypeValue = dictionary[.lastMessageType] as? String ?? "text"
        self.lastMessageType = MessageType(messageTypeValue) ?? .text
    }
}

extension Channel {
    static let placeholder = Channel(
        id: "1",
        name: "Placeholder Channel",
        lastMessage: "Hey, How'ya doing?",
        creationDate: Date(),
        lastMessageTimestamp: Date(),
        membersCount: 2,
        adminUids: [],
        membersUids: [],
        members: [],
        thumbnailURL: nil,
        createdBy: "",
        lastMessageType: .text
    )
}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailURL = "thumbnailURL"
    static let members = "members"
    static let createdBy = "createdBy"
    static let lastMessageType = "lastMessageType"
}
