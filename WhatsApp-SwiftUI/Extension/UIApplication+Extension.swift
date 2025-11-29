import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication.shared
            .sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
