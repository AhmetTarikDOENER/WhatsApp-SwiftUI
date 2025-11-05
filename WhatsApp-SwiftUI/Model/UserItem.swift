//  MARK: - UserItem
struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profilImageUrl: String? = nil
    
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
        self.profilImageUrl = dictionary[.profilImageUrl] as? String? ?? nil
    }
}

//  MARK: - String+Extension
extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profilImageUrl = "profilImageUrl"
}
