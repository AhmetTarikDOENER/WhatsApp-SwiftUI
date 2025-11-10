import FirebaseDatabase

struct UserService {
    
    static func paginateUsers(currentCursor: String?, pageSize: UInt) async throws -> UserNode {
        let mainSnapshot: DataSnapshot
        
        if currentCursor == nil {
            mainSnapshot = try await FirebaseConstants.UserReference
                .queryLimited(toLast: pageSize)
                .getData()
        } else {
            mainSnapshot = try await FirebaseConstants.UserReference
                .queryOrderedByKey()
                .queryEnding(atValue: currentCursor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
        }
        
        guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
              let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }
        
        let users: [UserItem] = allObjects.compactMap { userSnapshot in
            let userDictionary = userSnapshot.value as? [String: Any] ?? [:]
            return UserItem(dictionary: userDictionary)
        }
        
        if users.count == mainSnapshot.childrenCount {
            let filteredUsers = currentCursor == nil ? users : users.filter { $0.uid != currentCursor }
            let userNode = UserNode(users: filteredUsers, currentCursor: first.key)
            return userNode
        }
        
        return .emptyNode
    }
}

//  MARK: - UserNode
struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
