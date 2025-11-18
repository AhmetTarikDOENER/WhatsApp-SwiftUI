import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListController
    private var viewModel: ChatroomViewModel
    
    //  MARK: - Init
    init(_ viewModel: ChatroomViewModel) {
        self.viewModel = viewModel
    }
    
    //  MARK: - Internal
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController(viewModel)
        
        return messageListController
    }
    
    func updateUIViewController(
        _ uiViewController: MessageListController,
        context: Context
    ) { }
}

#Preview {
    MessageListView(.init(.placeholder))
}
