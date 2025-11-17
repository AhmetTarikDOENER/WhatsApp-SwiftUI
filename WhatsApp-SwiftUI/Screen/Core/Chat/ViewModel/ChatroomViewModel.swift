import Foundation
import Combine

final class ChatroomViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var textMessage = ""
    @Published var currentUser: UserItem?
    private var subscription = Set<AnyCancellable>()
    private let channel: Channel
    
    //  MARK: - Init & Deinit
    init(_ channel: Channel) {
        self.channel = channel
        listenAuthstate()
    }
    
    deinit {
        subscription.forEach { $0.cancel() }
        subscription.removeAll()
        currentUser = nil
    }
    
    //  MARK: - Internal & Private
    func sendMessage() {
        guard let currentUser else { return }
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
            self?.textMessage = ""
        }
    }
    
    private func listenAuthstate() {
        AuthenticationService.shared.authState.receive(on: DispatchQueue.main)
            .sink { authState in
                switch authState {
                case .loggedIn(let loggedInUser):
                    self.currentUser = loggedInUser
                default: break
                }
            }.store(in: &subscription)
    }
}
