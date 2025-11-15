import Foundation

final class ChannelTabViewModel: ObservableObject {
    
    @Published var navigateChatroom = false
    @Published var showChatPartnerPickerView = false
    @Published var newChannel: Channel?
    
    func onNewChannelCreation(_ channel: Channel) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateChatroom = true
    }
}
