import Foundation
import PhotosUI
import SwiftUI
import Combine

@MainActor
final class SettingsTabScreenViewModel: ObservableObject {
    
    //  MARK: - Properties
    @Published var selectedPhotoPickerItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachments?
    private var subscription: AnyCancellable?
    
    //  MARK: - Init & Deinit
    init() {
        onPhotoPickerSelection()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    //  MARK: - Private
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
}
