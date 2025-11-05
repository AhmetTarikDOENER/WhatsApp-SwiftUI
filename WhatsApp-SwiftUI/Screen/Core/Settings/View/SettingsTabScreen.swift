import SwiftUI

struct SettingsTabScreen: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView()
                
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
    var body: some View {
        HStack {
            Circle()
                .frame(width: 50, height: 50)
            
            userInfoTextView()
        }
        
        SettingsItemView(settingsItem: .avatar)
    }
    
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
}

#Preview {
    SettingsTabScreen()
}
