import SwiftUI

struct ChannelTabScreen: View {
    
    @State private var searchText = ""
    @StateObject private var viewModel = ChannelTabViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                archieveButton()
                
                ForEach(0 ..< 5) { _ in
                    NavigationLink {
                        ChatroomScreen(channel: .placeholder)
                    } label: {
                        ChannelItemView()
                    }
                }
                
                inboxFooterView()
                    .listRowSeparator(.hidden)
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .listStyle(.plain)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItemGroup()
            }
            .sheet(isPresented: $viewModel.showChatPartnerPickerView) {
                ChatPartnerPickerView(onCreate: viewModel.onNewChannelCreation)
            }
            .navigationDestination(isPresented: $viewModel.navigateChatroom) {
                if let newChannel = viewModel.newChannel {
                    ChatroomScreen(channel: newChannel)
                }
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
            viewModel.showChatPartnerPickerView = true
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
    
    private func inboxFooterView() -> some View {
        HStack {
            Image(systemName: "lock.fill")
            
            Text("Your personel messages are ")
            +
            Text("end-to-end encrypted")
                .foregroundStyle(.blue)
        }
        .foregroundStyle(.gray)
        .font(.caption)
        .padding(.horizontal)
    }
}

#Preview {
    ChannelTabScreen()
}
