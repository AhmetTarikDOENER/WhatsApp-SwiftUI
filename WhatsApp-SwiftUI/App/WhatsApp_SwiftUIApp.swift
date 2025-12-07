import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
    
        configureFirebase()
        setupPushNotification(for: application)
        
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
    
    private func setupPushNotification(for application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error {
                print("❌ APNS -> Apple Push Notification Auth error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("❌ APNS -> Apple Push Notification is not granted: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

//  MARK: - UNUserNotificationCenterDelegate & MessagingDelegate
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS successfully registered for PN with device token")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("APNS device token is: \(String(describing: fcmToken))")
    }
}

@main
struct WhatsApp_SwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootScreen()
        }
    }
}
