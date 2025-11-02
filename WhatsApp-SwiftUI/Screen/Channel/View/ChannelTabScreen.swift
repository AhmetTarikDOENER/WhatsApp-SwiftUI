import SwiftUI

struct ChannelTabScreen: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                archieveButton()
                
                ForEach(0 ..< 5) { _ in
                    ChannelItemView()
                }
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .listStyle(.plain)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
        }
    }
}

//  MARK: - ChannelTabScreen+Extension
private extension ChannelTabScreen {
    @ToolbarContentBuilder
    private func leadingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    
                } label: {
                    Label("Select Chats", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItemGroup() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            aiButton()
            cameraButton()
            newChatButton()
        }
    }
    
    private func aiButton() -> some View {
        Button {
            
        } label: {
            Image(.circle)
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera")
        }
    }
    
    private func newChatButton() -> some View {
        Button {
            
        } label: {
            Image(.plus)
        }
    }
    
    private func archieveButton() -> some View {
        Button {
            
        } label: {
            Label("Archived", systemImage: "archivebox.fill")
                .bold()
                .padding()
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ChannelTabScreen()
}
