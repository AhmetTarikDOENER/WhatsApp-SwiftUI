import SwiftUI

struct ChatroomScreen: View {
    
    //  MARK: - Properties
    @StateObject private var viewModel: ChatroomViewModel
    let channel: Channel
    
    //  MARK: - Init
    init(channel: Channel) {
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(channel))
    }
    
    var body: some View {
        MessageListView()
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                TextInputAreaView(textMessage: $viewModel.textMessage) {
                    viewModel.sendMessage()
                }
            }
    }
}

//  MARK: - ChatroomScreen+Extension
extension ChatroomScreen {
    @ToolbarContentBuilder
    private func leadingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Circle()
                    .frame(width: 35, height: 35)
                
                Text(channel.title)
                    .bold()
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItemGroup() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "video")
            }
            
            Button {
                
            } label: {
                Image(systemName: "phone")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatroomScreen(channel: .placeholder)
    }
}
