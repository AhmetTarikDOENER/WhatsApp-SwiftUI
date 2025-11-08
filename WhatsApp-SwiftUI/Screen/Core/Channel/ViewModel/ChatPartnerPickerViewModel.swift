import Foundation

//  MARK: - ChannelCreationRoute
enum ChannelCreationRoute {
    case groupChatPartnerPicker
    case setupGroupChat
}

//  MARK: - ChannelConstants
enum ChannelConstants {
    static let maxGroupParticipantCount = 12
}

//  MARK: - ChatPartnerPickerViewModel
@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var navigationStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published private(set) var users: [UserItem] = []
    private var currentCursor: String?
    
    var showSelectedUsers: Bool {
        !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        selectedChatPartners.isEmpty
    }
    
    var isPaginatable: Bool {
        !users.isEmpty
    }
    
    //  MARK: - Init
    init() { Task { await fetchUsers() } }
    
    //  MARK: - Internal
    func handleUserSelection(_ user: UserItem) {
        if isUserSelected(user) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == user.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            selectedChatPartners.append(user)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(currentCursor: currentCursor, pageSize: 5)
            self.users.append(contentsOf: userNode.users)
            self.currentCursor = userNode.currentCursor
        } catch {
            print("❌ ChatPartnerPickerViewModel -> Failed to fetch users: \(error.localizedDescription)")
        }
    }
}
