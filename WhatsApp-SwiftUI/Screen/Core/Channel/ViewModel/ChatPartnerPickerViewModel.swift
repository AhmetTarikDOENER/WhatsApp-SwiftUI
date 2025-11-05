import Foundation

//  MARK: - ChannelCreationRoute
enum ChannelCreationRoute {
    case addGroupChatMember
    case setupGroupChat
}

//  MARK: - ChatPartnerPickerViewModel
final class ChatPartnerPickerViewModel: ObservableObject {
    
    @Published var navigationStack = [ChannelCreationRoute]()
}
