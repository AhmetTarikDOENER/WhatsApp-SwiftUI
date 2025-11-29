import UIKit

extension UIWindowScene {
    
    static var currentWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }
    
    var screenWidth: CGFloat { UIWindowScene.currentWindowScene?.screen.bounds.width ?? 0 }
    
    var screenHeight: CGFloat { UIWindowScene.currentWindowScene?.screen.bounds.height ?? 0 }
}
