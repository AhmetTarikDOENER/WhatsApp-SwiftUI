import Foundation

//  MARK: - ChannelCreationRoute
enum ChannelCreationRoute {
    case addGroupChatMember
    case setupGroupChat
}

//  MARK: - ChatPartnerPickerViewModel
final class ChatPartnerPickerViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var navigationStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    
    var showSelectedUsers: Bool {
        !selectedChatPartners.isEmpty
    }
    
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
}
