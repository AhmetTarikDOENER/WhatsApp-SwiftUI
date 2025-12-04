import Foundation
import PhotosUI
import SwiftUI
import Combine
import FirebaseAuth
import AlertKit

@MainActor
final class SettingsTabScreenViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var selectedPhotoPickerItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachments?
    @Published var showProgressHUD = false
    @Published var showSuccessHUD = false
    @Published var isUserInfoEditorPresented = false
    @Published var username = ""
    @Published var bio = ""
    private var subscription: AnyCancellable?
    private(set) var progressHUDView = AlertAppleMusic17View(
        title: "Uploading Profile Photo...",
        subtitle: "Please wait a moment to complete the upload.",
        icon: .spinnerSmall
    )
    private(set) var successHUDView = AlertAppleMusic17View(
        title: "Profile Photo Uploaded Successfully!",
        subtitle: nil,
        icon: .done
    )
    
    private var currentUser: UserItem
    
    var disableSaveButton: Bool { profilePhoto == nil }
    
    //  MARK: - Init & Deinit
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self.username = currentUser.username
        self.bio = currentUser.bio ?? ""
        onPhotoPickerSelection()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    //  MARK: - Private & Internal
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoPickerItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem else { return }
                self?.parsePhotoPickerItem(photoItem)
            }
    }
    
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            self.profilePhoto = MediaAttachments(id: UUID().uuidString, type: .photo(uiImage))
        }
    }
    
    func saveProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        showProgressHUD = true
        FirebaseUploader.uploadImage(profilePhoto, for: .profile) { [weak self] result in
            switch result {
            case .success(let profilePhotoURL):
                self?.onUploadSuccess(profilePhotoURL)
            case .failure(let error):
                print("❌ SettingsTabScreenViewModel -> Failed to upload profile photo: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            
        }
    }
    
    private func onUploadSuccess(_ imageURL: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserReference.child(currentUid).child(.profileImageUrl).setValue(imageURL.absoluteString)
        showProgressHUD = false
        progressHUDView.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showSuccessHUD = true
            self.profilePhoto = nil
            self.selectedPhotoPickerItem = nil
        }
    }
    
    func updateUserProfileInformations() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var dictionary: [String: Any] = [.bio: bio]
        
        if !username.isEmptyOrWhitespace {
            dictionary[.username] = username
        }
        
        FirebaseConstants.UserReference.child(currentUid).updateChildValues(dictionary)
        showSuccessHUD = true
    }
}
