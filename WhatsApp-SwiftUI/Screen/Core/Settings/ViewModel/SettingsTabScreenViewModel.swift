import Foundation
import PhotosUI
import SwiftUI

final class SettingsTabScreenViewModel: ObservableObject {
    
    @Published var selectedPhotoPickerItem: PhotosPickerItem?
}
