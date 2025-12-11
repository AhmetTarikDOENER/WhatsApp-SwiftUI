//  MARK: - UserItem
struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    var username: String
    let email: String
    var bio: String? = nil
    var profileImageURL: String? = nil
    var fcmToken: String?
    var streamToken: String?
    
    var id: String { uid }
    var bioUnwrapped: String { bio ?? "Hey there! I am using WhatsApp" }
}

//  MARK: - UserItem+Extension
extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageURL = dictionary[.profileImageUrl] as? String? ?? nil
        self.fcmToken = dictionary[.fcmToken] as? String? ?? nil
        self.streamToken = dictionary[.streamToken] as? String? ?? nil
    }
    
    static let placeholder = UserItem(uid: "1", username: "timcook", email: "apple@apple.com")
    static let placeholders: [UserItem] = [
        .init(uid: "1", username: "timcook1", email: "apple1@apple.com"),
        .init(uid: "2", username: "timcook2", email: "apple2@apple.com"),
        .init(uid: "3", username: "timcook3", email: "apple3@apple.com"),
        .init(uid: "4", username: "timcook4", email: "apple4@apple.com"),
        .init(uid: "5", username: "timcook5", email: "apple5@apple.com"),
        .init(uid: "6", username: "timcook6", email: "apple6@apple.com"),
        .init(uid: "7", username: "timcook7", email: "apple7@apple.com"),
        .init(uid: "8", username: "timcook8", email: "apple8@apple.com")
    ]
}

//  MARK: - String+Extension
extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageURL"
    static let fcmToken = "fcmToken"
    static let streamToken = "streamToken"
}
