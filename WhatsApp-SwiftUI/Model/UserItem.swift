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
