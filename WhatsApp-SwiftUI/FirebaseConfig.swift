import Foundation

struct FirebaseConfig {
    
    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("⚠️ Missing or invalid value for key: \(key) in Info.plist")
        }
        
        return value
    }
    
    static let apiKey = value(for: "FIREBASE_API_KEY")
    static let gcmSenderID = value(for: "FIREBASE_GCM_SENDER_ID")
    static let googleAppID = value(for: "FIREBASE_GOOGLE_APP_ID")
    static let projectID = value(for: "FIREBASE_PROJECT_ID")
    static let storageBucket = value(for: "FIREBASE_STORAGE_BUCKET")
}
