import UIKit
import FirebaseStorage

//  MARK: - FirebaseUploaderError
enum FirebaseUploaderError: Error {
    case uploadImageFailure(_ description: String)
}

//  MARK: - FirebaseUploaderError+LocalizedDescription
extension FirebaseUploaderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .uploadImageFailure(let description): return description
        }
    }
}

typealias UploadCompletion = (Result<URL, Error>) -> Void
typealias ProgressHandler = (Double) -> Void

//  MARK: - FirebaseUploader
struct FirebaseUploader {
    
    static func uploadImage(
        _ image: UIImage,
        for uploadType: UploadType,
        completion: @escaping UploadCompletion,
        progressHandler: @escaping ProgressHandler
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let storageReference = uploadType.filePath
        let uploadTask = storageReference.putData(imageData) { _, error in
            if let error = error {
                print("❌ FirebaseUploader -> Failed to upload image to the FirebaseStorage")
                completion(.failure(FirebaseUploaderError.uploadImageFailure(error.localizedDescription)))
                return
            }
            
            storageReference.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }
}

//  MARK: - FirebaseUploader+UploadType
extension FirebaseUploader {
    enum UploadType {
        case profile
        case photoMessage
        case videoMessage
        case audioMessage
        
        var filePath: StorageReference {
            let fileName = UUID().uuidString
            switch self {
            case .profile:
                return FirebaseConstants.StorageRefenrence.child("profile_image_urls").child(fileName)
            case .photoMessage:
                return FirebaseConstants.StorageRefenrence.child("photo_messages").child(fileName)
            case .videoMessage:
                return FirebaseConstants.StorageRefenrence.child("video_messages").child(fileName)
            case .audioMessage:
                return FirebaseConstants.StorageRefenrence.child("audio_messages").child(fileName)
            }
        }
    }
}
