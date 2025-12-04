import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    
    @State private var searchText = ""
    @StateObject private var viewModel: SettingsTabScreenViewModel
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self._viewModel = StateObject(wrappedValue: SettingsTabScreenViewModel(currentUser))
    }
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel: viewModel, currentUser)
                
                Section {
                    SettingsItemView(settingsItem: .broadcastList)
                    SettingsItemView(settingsItem: .starredMessages)
                    SettingsItemView(settingsItem: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(settingsItem: .account)
                    SettingsItemView(settingsItem: .privacy)
                    SettingsItemView(settingsItem: .chats)
                    SettingsItemView(settingsItem: .notifications)
                    SettingsItemView(settingsItem: .storage)
                }
                
                Section {
                    SettingsItemView(settingsItem: .help)
                    SettingsItemView(settingsItem: .tellFriend)
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavigationBarItem()
                trailingNavigationBarItem()
            }
            .alert(isPresent: $viewModel.showProgressHUD, view: viewModel.progressHUDView)
            .alert(isPresent: $viewModel.showSuccessHUD, view: viewModel.successHUDView)
            .alert(
                "Update Your Username and Bio",
                isPresented: $viewModel.isUserInfoEditorPresented
            ) {
                TextField("Username", text: $viewModel.username)
                
                TextField("Bio", text: $viewModel.bio)
                
                Button("Update") { viewModel.updateUserProfileInformations() }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your new username and bio")
            }
        }
    }
}

//  MARK: - SettingsTabScreen
extension SettingsTabScreen {
    @ToolbarContentBuilder
    private func leadingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Sign Out") {
                Task { try? await AuthenticationService.shared.logOut() }
            }
            .foregroundStyle(.red)
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                viewModel.saveProfilePhoto()
            }
            .bold()
            .disabled(viewModel.disableSaveButton)
        }
    }
}

#Preview {
    SettingsTabScreen(.placeholder)
}
