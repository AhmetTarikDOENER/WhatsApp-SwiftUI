import UIKit

extension UIWindowScene {
    
    static var currentWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }
    
    var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    var screenHeight: CGFloat { UIScreen.main.bounds.height }
}
