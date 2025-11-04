import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
    
      configureFirebase()

    return true
  }
    
    private func configureFirebase() {
        let options = FirebaseOptions(
            googleAppID: FirebaseConfig.googleAppID,
            gcmSenderID: FirebaseConfig.gcmSenderID
        )
        
        options.apiKey = FirebaseConfig.apiKey
        options.projectID = FirebaseConfig.projectID
        options.storageBucket = FirebaseConfig.storageBucket
        
        FirebaseApp.configure(options: options)
    }
}

@main
struct WhatsApp_SwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
