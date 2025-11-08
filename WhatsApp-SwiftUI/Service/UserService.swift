import FirebaseDatabase

struct UserService {
    
    static func paginateUsers(currentCursor: String?, pageSize: UInt) async throws -> UserNode {
        if currentCursor == nil {
            let mainSnapshot = try await FirebaseConstants.UserReference
                .queryLimited(toLast: pageSize)
                .getData()
            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }
            
            let users: [UserItem] = allObjects.compactMap { userSnapshot in
                let userDictionary = userSnapshot.value as? [String: Any] ?? [:]
                return UserItem(dictionary: userDictionary)
            }
            
            if users.count == mainSnapshot.childrenCount {
                let userNode = UserNode(users: users, currentCursor: first.key)
                return userNode
            }
            
            return .emptyNode
        } else {
            return .emptyNode
        }
    }
}

//  MARK: - UserNode
struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
