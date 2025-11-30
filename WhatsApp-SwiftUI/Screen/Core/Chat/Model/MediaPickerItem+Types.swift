import SwiftUI

struct VideoPickerTransferable: Transferable {
    
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            return .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            let originalFile = receivedTransferredFile.file
            let uniqueFileName = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: originalFile, to: copiedFile)
            
            return .init(url: copiedFile)
        }
    }
}

//  MARK: - MediaAttachments
struct MediaAttachments: Identifiable {
    let id: String
    let type: MediaAttachmentsType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let thumbnail): return thumbnail
        case .video(let thumbnail, _): return thumbnail
        case .audio: return UIImage()
        }
    }
    
    var fileURL: URL? {
        switch type {
        case .photo: return nil
        case .video(_, let fileURL): return fileURL
        case .audio(let url, _): return url
        }
    }
    
    var audioDuration: TimeInterval? {
        switch type {
        case .audio(_, let audioDuration): return audioDuration
        default: return nil
        }
    }
}

//  MARK: - MediaAttachmentsType
enum MediaAttachmentsType: Equatable {
    case photo(_ thumbnailImage: UIImage)
    case video(_ thumbnailImage: UIImage, _ url: URL)
    case audio(_ url: URL, _ duration: TimeInterval)
    
    static func == (lhs: MediaAttachmentsType, rhs: MediaAttachmentsType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio): return true
        default: return false
        }
    }
}
