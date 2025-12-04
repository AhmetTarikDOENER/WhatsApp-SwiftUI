import SwiftUI
import PhotosUI

struct SettingsHeaderView: View {
    
    //  MARK: - Property
    @ObservedObject private var viewModel: SettingsTabScreenViewModel
    private let currentUser: UserItem
    
    //  MARK: - Init
    init(viewModel: SettingsTabScreenViewModel, _ currentUser: UserItem) {
        self.viewModel = viewModel
        self.currentUser = currentUser
    }
    
    var body: some View {
        HStack {
            profileImageView()
            
            userInfoTextView()
                .onTapGesture {
                    viewModel.isUserInfoEditorPresented = true
                }
        }
        
        PhotosPicker(
            selection: $viewModel.selectedPhotoPickerItem,
            matching: .not(.videos)
        ) {
            SettingsItemView(settingsItem: .avatar)
        }
    }
    
    //  MARK: - Private
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(currentUser.username)
                    .font(.title2)
                
                Spacer()
                
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text(currentUser.bioUnwrapped)
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
            CircularProfileImageView(currentUser.profileImageURL, size: .custom(55))
        }
    }
}

#Preview {
    SettingsHeaderView(viewModel: .init(.placeholder), .placeholder)
}
