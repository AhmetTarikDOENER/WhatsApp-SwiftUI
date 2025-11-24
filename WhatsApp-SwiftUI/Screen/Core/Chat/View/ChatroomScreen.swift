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
        MessageListView(viewModel)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                bottomSafeAreaView()
            }
    }
    
    //  MARK: - Private
    private func bottomSafeAreaView() -> some View {
        VStack(spacing: 0) {
            Divider()
            
            MediaAttachmentsPreview()
            
            Divider()
            
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
                CircularProfileImageView(channel, size: .mini)
                
                Text(truncatedChannelTitle)
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
    
    private var truncatedChannelTitle: String {
        let maxChar = 25
        let trailingChars = channel.title.count > maxChar ? "..." : ""
        let title = String(channel.title.prefix(maxChar) + trailingChars)
        
        return title
    }
}

#Preview {
    NavigationStack {
        ChatroomScreen(channel: .placeholder)
    }
}
