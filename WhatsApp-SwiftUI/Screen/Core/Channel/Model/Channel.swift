import Foundation

struct Channel: Identifiable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: UInt
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    var thumbnailUrl: String?
    
    var isGroupChat: Bool { membersCount > 2 }
}

extension Channel {
    init(_ dictionary: [String: Any]) {
        self.id = dictionary[.id] as? String ?? ""
        self.name = dictionary[.name] as? String ?? ""
        self.lastMessage = dictionary[.lastMessage] as? String ?? ""
        
        let creationInterval = dictionary[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        
        let lastMessageInterval = dictionary[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMessageInterval)
        
        self.membersCount = dictionary[.membersCount] as? UInt ?? 0
        self.adminUids = dictionary[.adminUids] as? [String] ?? []
        self.thumbnailUrl = dictionary[.thumbnailUrl] as? String ?? nil
        self.membersUids = dictionary[.membersUids] as? [String] ?? []
        self.members = dictionary[.members] as? [UserItem] ?? []
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
        thumbnailUrl: nil
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
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
}
