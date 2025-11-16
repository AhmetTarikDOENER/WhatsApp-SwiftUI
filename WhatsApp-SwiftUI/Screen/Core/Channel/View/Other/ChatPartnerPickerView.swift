import SwiftUI

struct ChatPartnerPickerView: View {
    
    //  MARK: - Property
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatPartnerPickerViewModel()
    var onCreate: (_ newChannel: Channel) -> Void
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationStack) {
            List {
                ForEach(ChatPartnerPickerOptions.allCases) { option in
                    HeaderRowView(option: option) {
                        guard option == ChatPartnerPickerOptions.newGroup else { return }
                        viewModel.navigationStack.append(.groupChatPartnerPicker)
                    }
                }
                
                Section {
                    ForEach(viewModel.users) { user in
                        ChatPartnerRowView(user: user)
                            .onTapGesture {
                                viewModel.selectedChatPartners.append(user)
                                let channelResult = viewModel.createChannel(nil)
                                switch channelResult {
                                case .success(let channel):
                                    onCreate(channel)
                                case .failure(let error):
                                    print("❌ ChatPartnerPickerView -> Failed to create channel: \(error.localizedDescription)")
                                }
                            }
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                        .bold()
                }
                
                if viewModel.isPaginatable {
                    loadMoreUsersView()
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ChannelCreationRoute.self) { route in
                destinationView(for: route)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search name or number"
            )
            .toolbar {
                trailingNavigationBarItem()
            }
        }
    }
    
    private func loadMoreUsersView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension ChatPartnerPickerView {
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupChatPartnerPicker:
            GroupChatPartnerPickerView(viewModel: viewModel)
        case .setupGroupChat:
            NewGroupSetupView(viewModel: viewModel, onCreate: onCreate)
        }
    }
}

//  MARK: - ChatPartnerPickerView
extension ChatPartnerPickerView {
    @ToolbarContentBuilder
    private func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            cancelButton()
        }
    }
    
    private func cancelButton() -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.footnote)
                .bold()
                .foregroundStyle(.gray)
                .padding(8)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
    }
}

//  MARK: - ChatPartnerPickerOptions
fileprivate enum ChatPartnerPickerOptions: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var iconName: String {
        switch self {
        case .newGroup: return "person.2.fill"
        case .newContact: return "person.fill.badge.plus"
        case .newCommunity: return "person.3.fill"
        }
    }
}

//  MARK: - ChatPartnerPickerView+HeaderRowView
extension ChatPartnerPickerView {
    
    private struct HeaderRowView: View {
        
        let option: ChatPartnerPickerOptions
        let onTapHandler: () -> Void
        
        var body: some View {
            Button {
                onTapHandler()
            } label: {
                rowActionButton()
            }
        }
        
        private func rowActionButton() -> some View {
            HStack {
                Image(systemName: option.iconName)
                    .font(.footnote)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                
                Text(option.title)
            }
        }
    }
}

#Preview {
    ChatPartnerPickerView { channel in
        
    }
}
