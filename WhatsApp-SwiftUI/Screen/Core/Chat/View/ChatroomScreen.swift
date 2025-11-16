import SwiftUI

struct ChatroomScreen: View {
    
    let channel: Channel
    
    var body: some View {
        MessageListView()
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                TextInputAreaView()
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
