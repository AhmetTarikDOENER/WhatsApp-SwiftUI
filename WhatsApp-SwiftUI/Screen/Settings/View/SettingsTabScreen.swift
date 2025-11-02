import SwiftUI

struct SettingsTabScreen: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
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
        }
    }
}

#Preview {
    SettingsTabScreen()
}
