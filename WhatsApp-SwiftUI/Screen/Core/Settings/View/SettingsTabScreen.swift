import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    
    @State private var searchText = ""
    @StateObject private var viewModel = SettingsTabScreenViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel: viewModel)
                
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
}

//  MARK: - SettingsHeaderView
private struct SettingsHeaderView: View {
    
    //  MARK: - Property
    @ObservedObject private var viewModel: SettingsTabScreenViewModel
    
    //  MARK: - Init
    init(viewModel: SettingsTabScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            profileImageView()
            
            userInfoTextView()
        }
        
        PhotosPicker(selection: $viewModel.selectedPhotoPickerItem) {
            SettingsItemView(settingsItem: .avatar)
        }
    }
    
    //  MARK: - Private
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Tim Cook")
                    .font(.title2)
                
                Spacer()
                
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text("Hey there! I am using WhatsApp")
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
    
    @ViewBuilder
    private func profileImageView() -> some View {
        if let profilePhoto = viewModel.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(nil, size: .custom(55))
        }
    }
}

#Preview {
    SettingsTabScreen()
}
