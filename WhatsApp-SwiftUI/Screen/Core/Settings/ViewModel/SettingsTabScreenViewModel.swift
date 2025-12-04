import Foundation
import PhotosUI
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class SettingsTabScreenViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var selectedPhotoPickerItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachments?
    private var subscription: AnyCancellable?
    
    var disableSaveButton: Bool { profilePhoto == nil }
    
    //  MARK: - Init & Deinit
    init() {
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
        profilePhoto = nil
        selectedPhotoPickerItem = nil
    }
}
