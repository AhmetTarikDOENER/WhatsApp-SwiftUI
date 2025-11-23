import Foundation
import Combine

final class ChatroomViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var textMessage = ""
    @Published var messages: [Message] = []
    private var currentUser: UserItem?
    private var subscription = Set<AnyCancellable>()
    private(set) var channel: Channel
    
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
            .sink { [weak self] authState in
                guard let self else { return }
                switch authState {
                case .loggedIn(let loggedInUser):
                    self.currentUser = loggedInUser
                    
                    if self.channel.allMembersFetched {
                        self.getMessages()
                    } else {
                        self.getAllChannelMembers()
                    }
                default: break
                }
            }.store(in: &subscription)
    }
    
    private func getMessages() {
        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            print(messages.map({ $0.text }))
        }
    }
    
    private func getAllChannelMembers() {
        guard let currentUser else { return }
        let alreadyFetchedMembers = channel.members.compactMap { $0.uid }
        var memberUidsToFetch = channel.membersUids.filter { !alreadyFetchedMembers.contains($0) }
        memberUidsToFetch = memberUidsToFetch.filter { $0 != currentUser.uid }
        UserService.getUsers(with: memberUidsToFetch) { [weak self] userNode in
            guard let self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.channel.members.append(currentUser)
            self.getMessages()
        }
    }
}
