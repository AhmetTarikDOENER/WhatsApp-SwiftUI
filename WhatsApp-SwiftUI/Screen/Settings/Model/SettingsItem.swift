import SwiftUI

struct SettingsItem {
    let imageName: String
    var imageType: SettingsImageType = .systemImage
    let backgroundColor: Color
    let title: String
        
    //  MARK: - SettingsImageType
    enum SettingsImageType {
        case systemImage, assetImage
    }
}

//  MARK: - SettingsItem+Extension
extension SettingsItem {
    static let avatar = SettingsItem(
        imageName: "photo",
        backgroundColor: .blue,
        title: "Change Profile Photo"
    )
    
    static let broadcastList = SettingsItem(
        imageName: "megaphone.fill",
        backgroundColor: .green,
        title: "Broadcast List"
    )
    
    static let starredMessages = SettingsItem(
        imageName: "star.fill",
        backgroundColor: .yellow,
        title: "Starred Messages"
    )
    
    static let linkedDevices = SettingsItem(
        imageName: "laptopcomputer",
        backgroundColor: .orange,
        title: "Linked Devices"
    )
    
    static let account = SettingsItem(
        imageName: "key.fill",
        backgroundColor: .purple,
        title: "Account"
    )
    
    static let privacy = SettingsItem(
        imageName: "lock.fill",
        backgroundColor: .cyan,
        title: "Privacy"
    )
    
    static let chats = SettingsItem(
        imageName: "whatsapp-black",
        imageType: .assetImage,
        backgroundColor: .blue,
        title: "Chats"
    )
    
    static let notifications = SettingsItem(
        imageName: "bell.badge.fill",
        backgroundColor: .red,
        title: "Notifications"
    )
    
    static let storage = SettingsItem(
        imageName: "photo",
        backgroundColor: .blue,
        title: "Change Profile Photo"
    )
    
    static let help = SettingsItem(
        imageName: "info",
        backgroundColor: .blue,
        title: "Help"
    )
    
    static let tellFriend = SettingsItem(
        imageName: "heart.fill",
        backgroundColor: .red,
        title: "Tell a Friend"
    )
    
    static let media = SettingsItem(
        imageName: "photo",
        backgroundColor: .pink,
        title: "Media, Links and Docs"
    )
    
    static let mute = SettingsItem(
        imageName: "speaker.wave.2.fill",
        backgroundColor: .cyan,
        title: "Mute"
    )
    
    static let wallpaper = SettingsItem(
        imageName: "circles.hexagongrid",
        backgroundColor: .brown,
        title: "Walpaper"
    )
}
