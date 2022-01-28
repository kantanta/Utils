import UIKit

extension UIWindow {
    public func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        rootViewController = viewController
        makeKeyAndVisible()

        guard animated else { return }
        
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
}
